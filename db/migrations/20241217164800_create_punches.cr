# +micrate Up
CREATE TABLE punches (
  id BIGSERIAL PRIMARY KEY,
  punchable_type VARCHAR(255),
  punchable_id BIGINT,
  hits INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  ends_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_punches_created_at ON punches(created_at);
CREATE INDEX idx_punches_punchable ON punches(punchable_type, punchable_id);
CREATE INDEX idx_punches_starts_at ON punches(starts_at);
CREATE INDEX idx_punches_ends_at ON punches(ends_at);

# +micrate Down
DROP TABLE IF EXISTS punches CASCADE;
