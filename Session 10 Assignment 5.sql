use music; 

-- 1
SELECT DISTINCT
    A.name
FROM
    (SELECT 
        artists.artist_name AS name, albums.album_year AS year
    FROM
        artists, albums
    WHERE
        artists.artist_id = albums.album_artist_id
            AND albums.album_type = 'compilation') A,
    (SELECT 
        artists.artist_name AS name, albums.album_year AS year
    FROM
        artists, albums
    WHERE
        artists.artist_id = albums.album_artist_id
            AND albums.album_type = 'live') B
WHERE
    A.year = B.year;
            
-- 2
SELECT DISTINCT
    artists.artist_name
FROM
    artists,
    albums
WHERE
    artists.artist_id = albums.album_artist_id
        AND albums.album_type = 'studio'
        AND artists.artist_name NOT IN (SELECT 
            artists.artist_name
        FROM
            artists,
            albums
        WHERE
            artists.artist_id = albums.album_artist_id
                AND NOT albums.album_type = 'studio');
                
-- 3
SELECT DISTINCT
    a.album_id, a.album_title
FROM
    albums a,
    artists art
WHERE
    a.album_artist_id = art.artist_id
        AND art.artist_type = 'band'
        AND NOT EXISTS( SELECT 
            b.album_title
        FROM
            albums b,
            artists art
        WHERE
            a.album_artist_id = b.album_artist_id
                AND a.album_year > b.album_year
                AND (a.album_rating < b.album_rating
                OR a.album_rating = b.album_rating));
    
-- 4
SELECT DISTINCT
    a.album_id, a.album_title
FROM
    albums a,
    artists art
WHERE
    art.nationality = 'English'
        AND a.album_type = 'live'
        AND a.album_rating > (SELECT 
            AVG(album_rating)
        FROM
            albums b
        WHERE
            b.album_year = a.album_year);

-- 5
SELECT DISTINCT
    song.track_name,
    album.album_title,
    artist.artist_name,
    song.track_length,
    album.album_year,
    album.album_rating
FROM
    tracks song,
    albums album,
    artists artist
WHERE
    song.track_length < 154
        AND song.track_album_id = album.album_id
        AND album.album_artist_id = artist.artist_id
        AND (2019 - album.album_year) < 20
        AND album_rating > 3;

-- 6
SELECT 
    SUM(total_length) / COUNT(*) AS 'avg_album_length'
FROM
    albums album,
    (SELECT 
        track_album_id,
            SUM(track_length) AS 'total_length',
            COUNT(DISTINCT track_id) AS 'counts'
    FROM
        tracks
    GROUP BY track_album_id
    HAVING COUNT(DISTINCT track_id) > 9) more9
WHERE
    album.album_id = more9.track_album_id
        AND album.album_year > 1989
        AND album.album_year < 2000;

-- 7
SELECT 
    artists.artist_id, artists.artist_name
FROM
    artists
WHERE
    artists.artist_id NOT IN (SELECT 
            album1.album_artist_id
        FROM
            albums album1,
            albums album2
        WHERE
            album1.album_artist_id = album2.album_artist_id
                AND album1.album_id <> album2.album_id
                AND album1.album_year > album2.album_year
                AND album1.album_type = 'studio'
                AND album2.album_type = 'studio'
                AND album1.album_year - album2.album_year > 4
                AND NOT EXISTS( SELECT 
                    *
                FROM
                    albums album3
                WHERE
                    album3.album_id <> album1.album_id
                        AND album3.album_id <> album2.album_id
                        AND album3.album_artist_id = album1.album_artist_id
                        AND (album3.album_year <= album1.album_year
                        AND album3.album_year >= album2.album_year)));

-- 8
SELECT 
    a.artist_id,
    a.artist_name,
    a.count AS live_compilation_count,
    b.count AS studio_count
FROM
    (SELECT 
        artist.artist_id,
            artist.artist_name,
            album.album_type,
            COUNT(*) AS count
    FROM
        artists artist, albums album
    WHERE
        artist.artist_id = album.album_artist_id
            AND (album.album_type = 'compilation'
            OR album.album_type = 'live')
    GROUP BY artist.artist_name) a,
    (SELECT 
        artist.artist_id,
            artist.artist_name,
            album.album_type,
            COUNT(*) AS count
    FROM
        artists artist, albums album
    WHERE
        artist.artist_id = album.album_artist_id
            AND album.album_type = 'studio'
    GROUP BY artist.artist_name) b
WHERE
    a.artist_name = b.artist_name
        AND a.count > b.count;

    
-- 9
SELECT 
    album.album_id, album.album_title, AVG(track.track_length)
FROM
    albums album,
    tracks track
WHERE
    album.album_id = track.track_album_id
GROUP BY album.album_title
HAVING COUNT(track.track_album_id) = MAX(track.track_number);

-- 10
SELECT 
    a.artist_id, a.artist_name
FROM
    artists a,
    albums b
WHERE
    a.artist_id IN (SELECT 
            artist_id
        FROM
            artists,
            albums
        WHERE
            artists.artist_id = albums.album_artist_id
                AND albums.album_type = 'studio'
        GROUP BY artists.artist_id
        HAVING COUNT(*) > 2)
        AND a.artist_id IN (SELECT 
            artist_id
        FROM
            artists,
            albums
        WHERE
            artists.artist_id = albums.album_artist_id
                AND albums.album_type = 'live'
        GROUP BY artists.artist_id
        HAVING COUNT(*) > 1)
        AND a.artist_id IN (SELECT 
            artist_id
        FROM
            artists,
            albums
        WHERE
            artists.artist_id = albums.album_artist_id
                AND albums.album_type = 'compilation'
        GROUP BY artists.artist_id
        HAVING COUNT(*) > 0)
        AND a.artist_id NOT IN (SELECT 
            artist_id
        FROM
            artists,
            albums
        WHERE
            artists.artist_id = albums.album_artist_id
                AND albums.album_rating < 3
        GROUP BY artist_id)
GROUP BY a.artist_id;

-- 11
SELECT 
    a.artist_id, a.artist_name
FROM
    artists a,
    albums b
WHERE
    a.artist_id = b.album_artist_id
        AND a.artist_type = 'band'
        AND a.nationality = 'American'
        AND b.album_year = (SELECT 
            MIN(c.album_year)
        FROM
            albums c
        WHERE
            b.album_artist_id = c.album_artist_id)
        AND b.album_rating = 5;

-- 12
SELECT 
    b.artist_name,
    CAST((SUM(CASE
            WHEN a.album_rating < 3 THEN 1
            ELSE 0
        END) / COUNT(*) * 100)
        AS DECIMAL (8 , 2 )) AS p
FROM
    albums a,
    artists b
WHERE
    a.album_artist_id = b.artist_id
GROUP BY a.album_artist_id
ORDER BY p ASC;

-- 13
SELECT 
    a.artist_name
FROM
    (SELECT 
        artists.artist_name,
            artists.nationality,
            COUNT(*) AS studio_count
    FROM
        artists, albums
    WHERE
        artists.artist_id = albums.album_artist_id
            AND albums.album_type = 'studio'
    GROUP BY artist_id
    ORDER BY nationality ASC , studio_count DESC) a
WHERE
    a.studio_count = (SELECT 
            MAX(studio_count)
        FROM
            (SELECT 
                artists.artist_name,
                    artists.nationality,
                    COUNT(*) AS studio_count
            FROM
                artists, albums
            WHERE
                artists.artist_id = albums.album_artist_id
                    AND albums.album_type = 'studio'
            GROUP BY artist_id
            ORDER BY nationality ASC , studio_count DESC) b
        WHERE
            a.nationality = b.nationality);


-- 14
SELECT 
    a.album_title, b.album_title
FROM
    albums a,
    albums b,
    artists a1,
    artists b1
WHERE
    a.album_artist_id = a1.artist_id
        AND b.album_artist_id = b1.artist_id
        AND a.album_id <> b.album_id
        AND a1.nationality <> b1.nationality
        AND a.album_rating > b.album_rating;

-- 15
SELECT 
    albums.album_title,
    SUM(CASE
        WHEN albums.album_id = tracks.track_album_id THEN 1
        ELSE 0
    END) AS track_count,
    CASE
        WHEN
            (SUM(CASE
                WHEN albums.album_id = tracks.track_album_id THEN 1
                ELSE 0
            END)) = 0
        THEN
            NULL
        ELSE albums.album_rating / (SUM(CASE
            WHEN albums.album_id = tracks.track_album_id THEN 1
            ELSE 0
        END))
    END AS ratio
FROM
    albums,
    tracks
GROUP BY albums.album_id
ORDER BY ratio DESC;