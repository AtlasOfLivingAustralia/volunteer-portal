CREATE TABLE IF NOT EXISTS stats_session_filter (
    session_id varchar(64) NOT NULL,
    project_id bigint NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (session_id, project_id)
);

CREATE INDEX IF NOT EXISTS stats_session_filter_session_id_idx
    ON stats_session_filter (session_id);

CREATE INDEX IF NOT EXISTS stats_session_filter_project_id_idx
    ON stats_session_filter (project_id);

CREATE INDEX IF NOT EXISTS stats_filter_created_idx
    ON stats_session_filter(created_at);
