ALTER TABLE movies ADD CONSTRAINT movies_runtime_check CHECK (runtime >= 0);
ALTER TABLE movies ADD CONSTRAINT genres_length_check CHECK (JSON_LENGTH(genres) BETWEEN 1 AND 5);
