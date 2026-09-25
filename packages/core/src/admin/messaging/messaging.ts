import { providerRate, whatsappTemplate } from "@dcard/db";
import { and, asc, desc, eq, lte, ne } from "drizzle-orm";
import { recordAudit } from "../../audit/audit.js";
import { inTransaction, type DbExecutor } from "../../db-types.js";
import { ConflictError, NotFoundError, ValidationError } from "../../errors.js";
import { requireAdmin } from "../event-types/event-types.js";

// Admin registry for Meta-approved WhatsApp variants and provider rates
// (docs/design/features/notifications.md MSG-5, MSG-9 and MSG-15).

export const ADMIN_MESSAGE_TYPES = [
  "contribution_request",
  "thank_you",
  "contribution_reminder",
  "invitation_card",
  "card_upgraded",
  "attendance_confirmation",
  "event_reminder",
  "post_event_thanks",
] as const;
export const TEMPLATE_LANGUAGES = ["sw", "en"] as const;
export const TEMPLATE_CATEGORIES = ["utility", "marketing", "authentication"] as const;
export const TEMPLATE_STATUSES = ["pending", "approved", "rejected", "paused"] as const;
export const RATE_PROVIDERS = ["meta", "nextsms"] as const;
export const RATE_CHANNELS = ["whatsapp", "sms"] as const;

export type AdminMessageType = (typeof ADMIN_MESSAGE_TYPES)[number];
export type TemplateLanguage = (typeof TEMPLATE_LANGUAGES)[number];
export type TemplateCategory = (typeof TEMPLATE_CATEGORIES)[number];
export type TemplateStatus = (typeof TEMPLATE_STATUSES)[number];
export type RateProvider = (typeof RATE_PROVIDERS)[number];
export type RateChannel = (typeof RATE_CHANNELS)[number];

export type WhatsappTemplateInput = {
  messageType: AdminMessageType;
  variantName: string;
  language: TemplateLanguage;
  metaTemplateName: string;
  category: TemplateCategory;
  bodyParams: string[];
  editableParams: string[];
  headerImage: boolean;
  confirmButtons: boolean;
  status: TemplateStatus;
  active: boolean;
};

export type ProviderRateInput = {
  provider: RateProvider;
  channel: RateChannel;
  category: string;
  market: string;
  priceTzs: string;
  effectiveFrom: Date;
};

const KEY = /^[a-z][a-z0-9_]{1,79}$/;
const META_NAME = /^[a-z][a-z0-9_]{1,511}$/;
const PARAM = /^[a-z][a-z0-9_]{0,63}$/;
const MARKET = /^[A-Z]{2,10}$/;
const PRICE = /^(?:0|[1-9]\d{0,7})(?:\.\d{1,4})?$/;

function cleanKey(value: string, path: string, pattern = KEY): string {
  const clean = value.trim().toLowerCase();
  if (!pattern.test(clean)) {
    throw new ValidationError("Some fields are invalid.", [{ path, message: "Use lowercase letters, digits and underscores." }]);
  }
  return clean;
}

function cleanParams(values: string[], path: string): string[] {
  const clean = values.map((value) => value.trim().toLowerCase());
  if (clean.some((value) => !PARAM.test(value)) || new Set(clean).size !== clean.length) {
    throw new ValidationError("Some fields are invalid.", [{ path, message: "Parameters must be unique lowercase keys." }]);
  }
  return clean;
}

function cleanTemplate(input: WhatsappTemplateInput): WhatsappTemplateInput {
  const bodyParams = cleanParams(input.bodyParams, "bodyParams");
  const editableParams = cleanParams(input.editableParams, "editableParams");
  const missing = editableParams.find((param) => !bodyParams.includes(param));
  if (missing) {
    throw new ValidationError("Some fields are invalid.", [
      { path: "editableParams", message: `Editable parameter "${missing}" must also be a body parameter.` },
    ]);
  }
  return {
    ...input,
    variantName: cleanKey(input.variantName, "variantName"),
    metaTemplateName: cleanKey(input.metaTemplateName, "metaTemplateName", META_NAME),
    bodyParams,
    editableParams,
  };
}

function cleanRate(input: ProviderRateInput): ProviderRateInput {
  const market = input.market.trim().toUpperCase();
  const category = input.category.trim().toLowerCase();
  const price = input.priceTzs.trim();
  const expected = input.provider === "meta" ? { channel: "whatsapp", categories: ["utility", "marketing", "service"] } : { channel: "sms", categories: ["sms_segment"] };
  const issues = [
    ...(input.channel === expected.channel ? [] : [{ path: "channel", message: `Use ${expected.channel} for ${input.provider}.` }]),
    ...(expected.categories.includes(category) ? [] : [{ path: "category", message: `Unsupported category for ${input.provider}.` }]),
    ...(MARKET.test(market) ? [] : [{ path: "market", message: "Use a 2–10 letter market code." }]),
    ...(PRICE.test(price) ? [] : [{ path: "priceTzs", message: "Use a non-negative TZS amount with up to 4 decimal places." }]),
    ...(Number.isFinite(input.effectiveFrom.getTime()) ? [] : [{ path: "effectiveFrom", message: "Use a valid date and time." }]),
  ];
  if (issues.length) throw new ValidationError("Some fields are invalid.", issues);
  return { ...input, category, market, priceTzs: Number(price).toFixed(4) };
}

export async function listWhatsappTemplates(db: DbExecutor, actorId: string) {
  await requireAdmin(db, actorId);
  return db
    .select()
    .from(whatsappTemplate)
    .orderBy(asc(whatsappTemplate.messageType), asc(whatsappTemplate.variantName), asc(whatsappTemplate.language));
}

/** Variants hosts may choose: approved and active; paused is therefore excluded. */
export async function listAvailableWhatsappTemplates(
  db: DbExecutor,
  filters: { messageType?: AdminMessageType; language?: TemplateLanguage } = {},
) {
  const clauses = [eq(whatsappTemplate.active, true), eq(whatsappTemplate.status, "approved")];
  if (filters.messageType) clauses.push(eq(whatsappTemplate.messageType, filters.messageType));
  if (filters.language) clauses.push(eq(whatsappTemplate.language, filters.language));
  return db
    .select()
    .from(whatsappTemplate)
    .where(and(...clauses))
    .orderBy(asc(whatsappTemplate.messageType), asc(whatsappTemplate.variantName), asc(whatsappTemplate.language));
}

export async function createWhatsappTemplate(db: DbExecutor, actorId: string, input: WhatsappTemplateInput) {
  await requireAdmin(db, actorId);
  const values = cleanTemplate(input);
  return inTransaction(db, async (tx) => {
    const [created] = await tx
      .insert(whatsappTemplate)
      .values(values)
      .onConflictDoNothing({
        target: [whatsappTemplate.messageType, whatsappTemplate.variantName, whatsappTemplate.language],
      })
      .returning();
    if (!created) throw new ConflictError("That message type, variant and language already exist.");
    await recordAudit(tx, {
      actorUserId: actorId,
      action: "whatsapp_template.created",
      targetType: "whatsapp_template",
      targetId: created.id,
      newValue: values,
    });
    return created;
  });
}

export async function updateWhatsappTemplate(
  db: DbExecutor,
  actorId: string,
  id: string,
  input: Partial<WhatsappTemplateInput>,
) {
  await requireAdmin(db, actorId);
  const [row] = await db.select().from(whatsappTemplate).where(eq(whatsappTemplate.id, id));
  if (!row) throw new NotFoundError("WhatsApp template not found.");
  const next = cleanTemplate({
    messageType: input.messageType ?? row.messageType,
    variantName: input.variantName ?? row.variantName,
    language: input.language ?? row.language,
    metaTemplateName: input.metaTemplateName ?? row.metaTemplateName,
    category: input.category ?? row.category,
    bodyParams: input.bodyParams ?? row.bodyParams,
    editableParams: input.editableParams ?? row.editableParams,
    headerImage: input.headerImage ?? row.headerImage,
    confirmButtons: input.confirmButtons ?? row.confirmButtons,
    status: input.status ?? row.status,
    active: input.active ?? row.active,
  });
  const [duplicate] = await db
    .select({ id: whatsappTemplate.id })
    .from(whatsappTemplate)
    .where(
      and(
        eq(whatsappTemplate.messageType, next.messageType),
        eq(whatsappTemplate.variantName, next.variantName),
        eq(whatsappTemplate.language, next.language),
        ne(whatsappTemplate.id, id),
      ),
    );
  if (duplicate) throw new ConflictError("That message type, variant and language already exist.");
  return inTransaction(db, async (tx) => {
    const [updated] = await tx.update(whatsappTemplate).set(next).where(eq(whatsappTemplate.id, id)).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      action: "whatsapp_template.updated",
      targetType: "whatsapp_template",
      targetId: id,
      oldValue: row,
      newValue: next,
    });
    return updated!;
  });
}

export async function listProviderRates(db: DbExecutor, actorId: string) {
  await requireAdmin(db, actorId);
  const rows = await db
    .select()
    .from(providerRate)
    .orderBy(asc(providerRate.provider), asc(providerRate.category), desc(providerRate.effectiveFrom));
  return rows.map((row) => ({ ...row, provider: row.provider as RateProvider }));
}

export async function createProviderRate(db: DbExecutor, actorId: string, input: ProviderRateInput) {
  await requireAdmin(db, actorId);
  const values = cleanRate(input);
  return inTransaction(db, async (tx) => {
    const [created] = await tx.insert(providerRate).values(values).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      action: "provider_rate.created",
      targetType: "provider_rate",
      targetId: created!.id,
      newValue: { ...values, effectiveFrom: values.effectiveFrom.toISOString() },
    });
    return created!;
  });
}

/** Returns the provider rate in force at the send time. */
export async function getProviderRateAt(
  db: DbExecutor,
  criteria: { provider: RateProvider; channel: RateChannel; category: string; market: string; at: Date },
) {
  const [rate] = await db
    .select()
    .from(providerRate)
    .where(
      and(
        eq(providerRate.provider, criteria.provider),
        eq(providerRate.channel, criteria.channel),
        eq(providerRate.category, criteria.category.trim().toLowerCase()),
        eq(providerRate.market, criteria.market.trim().toUpperCase()),
        lte(providerRate.effectiveFrom, criteria.at),
      ),
    )
    .orderBy(desc(providerRate.effectiveFrom))
    .limit(1);
  return rate ?? null;
}
