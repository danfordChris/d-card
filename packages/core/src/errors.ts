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
