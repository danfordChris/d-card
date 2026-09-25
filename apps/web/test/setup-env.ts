process.env.DATABASE_URL ??= "postgres://dcard:dcard@localhost:55432/dcard";
process.env.AUTH_VERIFIER = "fake";
process.env.TOKEN_HASH_SECRET ??= "test-token-hash-secret-0123456789abcdef";
process.env.REDIS_URL ??= "redis://localhost:56379";
process.env.QUEUE_PREFIX = `webtest_${process.pid}`;
process.env.APP_URL = "https://dcard.test";
