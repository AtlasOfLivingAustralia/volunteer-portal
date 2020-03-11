CREATE TABLE task_descriptor (
  id BIGSERIAL PRIMARY KEY,
  retries_remaining INT NOT NULL DEFAULT 3,
  time_created TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,

  project_id BIGINT NOT NULL REFERENCES project(id) ON DELETE CASCADE,
  project_name text NOT NULL,
  external_identifier text NOT NULL,
  image_url text NOT NULL,
  fields JSONB NOT NULL,
  replace_duplicates BOOLEAN NOT NULL,
  after_load text
);

CREATE INDEX task_descriptor_time ON task_descriptor(time_created);
CREATE INDEX task_descriptor_retries ON task_descriptor(retries_remaining);

CREATE TABLE media_load_descriptor(
    task_descriptor_id BIGINT PRIMARY KEY REFERENCES task_descriptor(id) ON DELETE CASCADE,
    media_url text NOT NULL,
    mime_type text NOT NULL,
    after_download text
);

CREATE TABLE shadow_file_descriptor(
    task_descriptor_id BIGINT PRIMARY KEY REFERENCES task_descriptor(id) ON DELETE CASCADE,
    name text NOT NULL,
    record_idx INT NOT NULL,
    value text NOT NULL
);