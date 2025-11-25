# Supabase Data Synchronization Specification

## 1. Overview
This document outlines the strategy for synchronizing user data between the local device (SQLite/Drift) and Supabase. The system supports offline-first usage, automatic background syncing, and user identification via Email (derived from Google Sign-In).

## 2. User Identification
The app currently uses `google_sign_in` for Google Drive backups. We will leverage this identity.
*   **Primary Identifier:** User Email Address.
*   **Authentication:** 
    *   *Preferred:* Exchange Google ID Token for Supabase Session (provides proper RLS security).
    *   *Fallback:* Use Email as a simple column identifier (requires careful RLS setup or open access).
    *   *Decision:* We will implement a `signInWithGoogle` method in `SupabaseService` that accepts the `GoogleSignInAuthentication` tokens to properly authenticate the user in Supabase. This allows us to use the secure `auth.uid()` in Supabase RLS policies.

## 3. Database Schema Changes (Local - Drift)
To ensure robust synchronization and avoid ID collisions across devices, we will implement **Client-Side UUIDs**.

### New Columns for All Syncable Tables:
*   `id`: `TEXT` (UUID) - **New Primary Key Strategy**. While we might keep the auto-increment `int id` for internal Drift efficiency/foreign keys, the `uuid` will be the canonical ID for sync.
    *   *Implementation Note:* We will add a `uuid` column. For existing rows, we will backfill with generated UUIDs during migration.
*   `sync_status`: `INTEGER` (Enum: 0=Synced, 1=Pending Insert, 2=Pending Update, 3=Pending Delete) - Defaults to 1 (Pending Insert) for new rows.
*   `last_updated_at`: `DATETIME` - Automatically updated on local changes.

**Tables to Update:**
*   `user_profile`
*   `assessments`
*   `cognitive_exercises`
*   `cambridge_assessments`
*   `daily_goals`

## 4. Supabase Schema (Remote)
Supabase tables will use the UUID as the Primary Key.

**Common Columns:**
*   `id`: UUID (Primary Key) - Matches local `uuid`.
*   `user_id`: UUID (Foreign Key to `auth.users`)
*   `email`: Text (Optional, for redundancy/debugging)
*   `updated_at`: Timestamptz

## 5. Synchronization Logic (UUID Based)

### 5.1 Startup Sync (Pull & Push)
... (Same high-level logic, but matching is done via UUID)

### 5.2 Conflict Resolution
*   **Last Write Wins:** Compare `updated_at` timestamps.
*   **UUIDs:** Eliminate ID collision issues completely.

## 6. Implementation Plan (TDD First)

### Step 1: TDD - Local Schema Migration
1.  **Write Test:** Create `test/unit/database_migration_test.dart`.
    *   Test that new tables have `uuid` and `sync_status` columns.
    *   Test that inserting a row generates/requires a UUID.
    *   Test that migration backfills existing rows with UUIDs.
2.  **Implement:**
    *   Modify `database.dart` to add columns.
    *   Write migration logic in `AppDatabase`.
    *   Run `drift_dev` to generate code.

### Step 2: TDD - Sync Service Logic
1.  **Write Test:** Create `test/unit/sync_service_test.dart`.
    *   Mock Supabase client and Database.
    *   Test `syncPendingData`: verifies it selects `sync_status != 0` rows and calls Supabase `upsert`.
    *   Test `fetchRemoteData`: verifies it inserts remote rows into local DB.
2.  **Implement:** Update `SupabaseService` methods.

### Step 3: Integration
...

## 7. User Experience
*   **Sync Indicator:** Small icon in settings or app bar showing Sync Status (Green Check = Synced, Cloud w/ Slash = Offline/Pending).
*   **Conflict Resolution:** Last Write Wins (simplest for this use case). Remote timestamp vs Local timestamp.

