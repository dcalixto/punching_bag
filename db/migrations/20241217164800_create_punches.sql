-- +micrate Up
CREATE TABLE punches (
  id BIGSERIAL PRIMARY KEY,
  punchable_type VARCHAR(255),
  punchable_id BIGINT,
  hits INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  ends_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX punchable_index ON punches (punchable_type, punchable_id);
CREATE INDEX created_at_index ON punches (created_at);

-- +micrate Down
DROP TABLE IF EXISTS punches;
DROP INDEX IF EXISTS punchable_index;
DROP INDEX IF EXISTS created_at_index;
