CREATE INDEX IF NOT EXISTS field_scientific_name_value_idx
    ON field USING btree (value)
    WHERE name = 'scientificName';

CREATE INDEX IF NOT EXISTS field_scientific_name_task_value_idx
    ON field USING btree (task_id, value)
    WHERE name = 'scientificName';

