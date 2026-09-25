import { previewFileImport, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

const MAX_BYTES = 2 * 1024 * 1024;

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    let file: FormDataEntryValue | null;
    try {
      file = (await request.formData()).get("file");
    } catch {
      throw new ValidationError("Send the file as multipart/form-data in the `file` field.", [{ path: "file", message: "Missing." }]);
    }
    if (!(file instanceof File)) throw new ValidationError("Choose a file to upload.", [{ path: "file", message: "Missing." }]);
    if (file.size > MAX_BYTES) throw new ValidationError("The file is larger than 2 MB.", [{ path: "file", message: "Too large." }]);
    const preview = await previewFileImport(getDb(), user.id, eventId, {
      name: file.name,
      buffer: Buffer.from(await file.arrayBuffer()),
    });
    return Response.json(toJson(preview), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}
