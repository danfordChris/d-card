/** Base class for expected, user-facing domain errors. `code` is stable and safe to return in APIs. */
export class DomainError extends Error {
  constructor(
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = new.target.name;
  }
}

export class InvalidPhoneError extends DomainError {
  constructor(readonly input: string) {
    super("invalid_phone", "Phone number must be a Tanzanian number: 255 followed by 9 digits.");
  }
}

export class UnauthorizedError extends DomainError {
  constructor(message = "Authentication required.") {
    super("unauthorized", message);
  }
}

export class ForbiddenError extends DomainError {
  constructor(message = "You do not have access to this resource.") {
    super("forbidden", message);
  }
}

export class NotFoundError extends DomainError {
  constructor(message = "Resource not found.") {
    super("not_found", message);
  }
}

export type ValidationIssue = { path: string; message: string };

export class ValidationError extends DomainError {
  constructor(
    message = "Some fields are invalid.",
    readonly issues: ValidationIssue[] = [],
  ) {
    super("validation_error", message);
  }
}

export class ConflictError extends DomainError {
  constructor(message = "This action conflicts with the current state.") {
    super("conflict", message);
  }
}

export class PlanLimitError extends DomainError {
  constructor(message = "Your plan does not include this.") {
    super("plan_limit", message);
  }
}
