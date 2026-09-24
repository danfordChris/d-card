# Offline Check-in and Sync

## Context

- Applies to the D-Card Door app and the sync API.

## Offline Check-in and Sync
### 9.1 Local cache
- When online, the app downloads and keeps updated, for its event: invitations (name(s), card number, **hash** of the QR token, card type, total and used entries, status, table) and the list of walk-in approvers.
- The cache is stored in **encrypted SQLite (`sqflite_sqlcipher`)**, with the key in the device keystore (`flutter_secure_storage`). Small settings use `shared_preferences`.
- The cache is **encrypted on the device** and **wiped automatically** after the event (e.g. 24 h after the event ends) or when the host revokes the device.
- The app pulls changes regularly while online (a delta sync using an `updated_since` cursor), so offline decisions use recent data.

### 9.2 Entries as a CRDT
- Each entry is an **immutable event** with a device-generated UUID: `{id, invitation_id, admitted_count, method, staff_id, device_id, occurred_at}`.
- The server stores entries as a **grow-only set (G-Set CRDT)** keyed by `id`. Merging is **commutative, associative and idempotent**, so entries can sync in any order, any number of times, from any device, without conflicts.
- `entries_used` for a card is **derived** from the set of its entries. It is never overwritten by a device.
- Other offline actions (refused attempts, lockouts) are uploaded the same way as append-only events.

### 9.3 What a CRDT cannot prevent
A CRDT merges data without conflicts, but it **cannot enforce a limit across devices that cannot talk to each other**. If two offline gates admit on the same card, both entries are real people and both are kept. After sync:
- the card is marked **over-used**,
- the host gets an alert with both entries (gate, staff, time),
- the event is audited.

While a device is **online**, the atomic server check prevents over-use completely.

### 9.4 Sync behaviour
- Unsynced entries upload automatically as soon as the network returns, with retries.
- The app shows the sync status (e.g. "12 entries waiting to sync").
- The host dashboard shows devices with unsynced entries and when each last synced.
