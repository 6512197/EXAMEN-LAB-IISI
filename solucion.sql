-- IISSI-1

-- Tablas
DROP TABLE IF EXISTS Friendships;

DROP TABLE IF EXISTS UsersAchievements;

DROP TABLE IF EXISTS Achievements;

DROP TABLE IF EXISTS Reviews;

DROP TABLE IF EXISTS GenresVideogames;

DROP TABLE IF EXISTS Genres;

DROP TABLE IF EXISTS UsersVideogames;

DROP TABLE IF EXISTS Videogames;

DROP TABLE IF EXISTS Platforms;

DROP TABLE IF EXISTS Users;

--Gestionar artículos técnicos sobre videojuegos. Un artículo contiene: videojuego, título, número de palabras, y fecha de publicación.
CREATE TABLE Articulos (
    idArticulo INT AUTO_INCREMENT PRIMARY KEY,
    idVideojuego INT NOT NULL,
    titular VARCHAR(255) NOT NULL,
    numPalabras INT NOT NULL check (numPalabras BETWEEN 100 AND 2500),
    fechaPublicacion DATE NOT NULL,
	check (YEAR (fechaPublicacion) < 2100),-- Fecha de publicación no puede ser posterior al año 2100.
    FOREIGN KEY (idVideojuego) REFERENCES Videogames(idVideogame),
	--No se puede publicar más de un artículo por videojuego al mismo día.
    CONSTRAINT unicaPorJuegoYFecha UNIQUE (idVideojuego, fechaPublicacion),
   
);

-- Usuarios
CREATE TABLE IF NOT EXISTS Users (
  idUser INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  email VARCHAR(64) NOT NULL,
  passwd VARCHAR(256) NOT NULL,
  age tinyint(4) NOT NULL DEFAULT 18,
  PRIMARY KEY (idUser),
  UNIQUE (email)
);

-- Plataformas
CREATE TABLE IF NOT EXISTS Platforms (
	idPlatform INT(11) NOT NULL,
	name VARCHAR(64) NOT NULL UNIQUE,
	isHandheld BOOLEAN, -- Handheld = Portátil
	PRIMARY KEY (idPlatform)
);

-- Videojuegos
CREATE TABLE IF NOT EXISTS Videogames (
  idVideogame INT(11) NOT NULL AUTO_INCREMENT,
  idPlatform INT(11),
  price DECIMAL(4,2),
  name VARCHAR(128) NOT NULL,
  releaseDate DATE,
  score DECIMAL(4,2),
  uniqueCode VARCHAR(64) NOT NULL UNIQUE,
  PRIMARY KEY (idVideogame),
  FOREIGN KEY (idPlatform) REFERENCES Platforms(idPlatform),
  CONSTRAINT negativePrice CHECK (price >= 0.0),
  CONSTRAINT scoreLimits CHECK (score BETWEEN 0 AND 10)
);

CREATE TABLE IF NOT EXISTS UsersVideogames (
  idUserVideogame INT(11) NOT NULL AUTO_INCREMENT,
  idUser INT(11) NOT NULL,
  idVideogame INT(11) NOT NULL,
  PRIMARY KEY (idUserVideogame),
  FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (idVideogame) REFERENCES Videogames(idVideogame) ON DELETE CASCADE
);

-- Géneros
CREATE TABLE IF NOT EXISTS Genres (
  idGenre INT(11) NOT NULL AUTO_INCREMENT,
  description VARCHAR(64) NOT NULL,
  PRIMARY KEY (idGenre)
);

CREATE TABLE IF NOT EXISTS GenresVideogames(
	idGenreVideogame INT(11) NOT NULL AUTO_INCREMENT,
	idGenre INT(11) NOT NULL,
	idVideogame INT(11) NOT NULL,
	PRIMARY KEY (idGenreVideogame),
	FOREIGN KEY (idGenre) REFERENCES Genres(idGenre) ON DELETE CASCADE,
	FOREIGN KEY (idVideogame) REFERENCES Videogames(idVideogame) ON DELETE CASCADE,
  UNIQUE (idGenre,idVideogame)
);

-- Reviews
CREATE TABLE IF NOT EXISTS Reviews (
	idReview INT(11) NOT NULL AUTO_INCREMENT,
	idUser INT(11) NOT NULL,
	idVideogame INT(11) NOT NULL,
	reviewText VARCHAR(512),
	rating DECIMAL(4,2) NOT NULL, -- Puntuación de 1 a 5
	reviewDate DATETIME DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (idReview),
	FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
	FOREIGN KEY (idVideogame) REFERENCES Videogames(idVideogame) ON DELETE CASCADE,
	CONSTRAINT validRating CHECK (rating BETWEEN 0 AND 10)
);

-- Logros
CREATE TABLE IF NOT EXISTS Achievements (
  idAchievement INT(11) NOT NULL AUTO_INCREMENT,
  idVideogame INT(11) NOT NULL,
  title VARCHAR(128) NOT NULL,
  description VARCHAR(512) NOT NULL,
  points INT(11) NOT NULL DEFAULT 10, -- Valor del logro en puntos
  PRIMARY KEY (idAchievement),
  FOREIGN KEY (idVideogame) REFERENCES Videogames(idVideogame) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS UsersAchievements (
  idUserAchievement INT(11) NOT NULL AUTO_INCREMENT,
  idUser INT(11) NOT NULL,
  idAchievement INT(11) NOT NULL,
  achievementDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idUserAchievement),
  FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (idAchievement) REFERENCES Achievements(idAchievement) ON DELETE CASCADE,
  UNIQUE (idUser, idAchievement) -- Evita logros duplicados por usuario
);

-- Amistades
CREATE TABLE IF NOT EXISTS Friendships (
  idFriendship INT(11) NOT NULL AUTO_INCREMENT,
  idUser1 INT(11) NOT NULL,
  idUser2 INT(11) NOT NULL,
  friendshipDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idFriendship),
  FOREIGN KEY (idUser1) REFERENCES Users(idUser) ON DELETE CASCADE,
  FOREIGN KEY (idUser2) REFERENCES Users(idUser) ON DELETE CASCADE,
  CHECK (idUser1 <> idUser2), -- Impide la autorelación (un usuario no puede ser amigo de sí mismo)
  UNIQUE (idUser1, idUser2)   -- Evita duplicados en relaciones de amistad
);

-- Triggers

DELIMITER //
CREATE OR REPLACE TRIGGER tMaximoVideojuegosUsuario
  BEFORE INSERT ON UsersVideogames
  FOR EACH ROW
  BEGIN
    DECLARE videojuegosActuales INT;
    SET videojuegosActuales = (SELECT COUNT(*) FROM UsersVideogames UV WHERE UV.idUser = new.idUser);
    IF (videojuegosActuales >= 10) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un usuario no puede tener mas de 10 videojuegos.';
    END IF;
  END//
DELIMITER ;

DELETE FROM Friendships;
DELETE FROM UsersAchievements;
DELETE FROM Achievements;
DELETE FROM Reviews;
DELETE FROM GenresVideogames;
DELETE FROM Genres;
DELETE FROM UsersVideogames;
DELETE FROM Videogames;
DELETE FROM Platforms;
DELETE FROM Users;

INSERT INTO Articulos (idVideojuego, titular, numPalabras, fechaPublicacion) VALUES
	(3, 'Articulo 1', 150, '2023-10-01'),
	(4, 'articulo 2', 300, '1995-12-12'),
	(5, 'Articulo 3', 200, '2023-10-02'),
	(6, 'Articulo 4', 400, '2023-10-03'),
	(7, 'Articulo 5', 500, '2023-10-04'),
	(8, 'Articulo 6', 600, '2023-10-05'),
	(9, 'Articulo 7', 700, '2023-10-06'),
	(10, 'Articulo 8', 800, '2023-10-07'),
	(11, 'Articulo 9', 900, '2023-10-08'),
	(12, 'Articulo 10', 1000, '2023-10-09');
	()
INSERT INTO Noticias (idVideojuego, titular, numPalabras, fechaPublicacion) VALUES
	(1, 'RHEM I SE: The Mysterious Land - Análisis Completo', 1200, '2023-10-01'),
	(2, 'RHEM II SE: The Cave - Estrategias y Consejos', 1500, '2023-10-02'),
	(3, 'RHEM III SE: The Secret Library - Guía de Puzzles', 1300, '2023-10-03'),
	(4, 'RHEM IV SE: The Golden Fragments - Todo lo que necesitas saber', 1400, '2023-10-04'),
	(5, 'Myst - Un Clásico Inolvidable', 1600, '2023-10-05');


INSERT INTO Genres (idGenre, description) VALUES
	(1, 'Point and Click'),
	(2, 'Shooter'),
	(3, 'Plataformas'),
	(4, 'Aventura'),
	(5, 'Lucha'),
	(6, 'RPG'),
	(7, 'Puzzles'),
	(8, 'Estrategia');

INSERT INTO Platforms(idPlatform, name, isHandheld) VALUES
	(1, 'PC', NULL),
	(2, 'Playstation 1', 0),
	(3, 'Game Boy Advance', 1),
	(4, 'Switch', NULL),
	(5, 'Playstation 5', 0),
	(6, 'Nintendo DS', 1),
	(7, 'XBox 360', 0),
	(8, 'Nintendo 3DS', 1);

-- Contrasenya: iissi
INSERT INTO Users (idUser, name, email, passwd, age) VALUES
	(1, 'David Ruiz', 'druiz@us.es', 'pbkdf2:sha256:150000$MjN72ikE$897d960e08be9150d943c747ff6194904fd325821945ff7d7f5c1d1d08b40bbd', 45),
	(2, 'Daniel Ayala', 'dayala1@us.es', 'pbkdf2:sha256:150000$MjN72ikE$897d960e08be9150d943c747ff6194904fd325821945ff7d7f5c1d1d08b40bbd', 28),
	(3, 'Carlos Arévalo', 'carevalo@us.es', 'pbkdf2:sha256:150000$MjN72ikE$897d960e08be9150d943c747ff6194904fd325821945ff7d7f5c1d1d08b40bbd', 55),
	(4, 'Alfonso Márquez', 'amarquez@us.es', 'pbkdf2:sha256:150000$MjN72ikE$897d960e08be9150d943c747ff6194904fd325821945ff7d7f5c1d1d08b40bbd', 35);


INSERT INTO Videogames (idVideogame, idPlatform, uniqueCode, price, name, releaseDate, score) VALUES
	(1, 1, 'R11', 6.89, 'RHEM I SE: The Mysterious Land', '2017-07-28', 10.0),
	(2, 1, 'R21', 8.19, 'RHEM II SE: The Cave', '2018-10-03', 10.0),
	(3, 1, 'R31', 8.99, 'RHEM III SE: The Secret Library', '2021-03-25', 10.0),
	(4, 1, 'R41', 9.99, 'RHEM IV SE: The Golden Fragments', '2016-02-03', 10.0),
	(5, 1, 'M51', 10.00, 'Myst', '1993-09-24', 8.0),
	(6, 1, 'R61', 10.00, 'Riven', '1997-10-31', 10.0),
	(7, 1, 'R71', 9.95, 'Rayman', '1996-04-30', 9.0),
	(8, 2, 'R82', 9.99, 'Rayman', '1995-09-01', 9.0),
	(9, 2, 'C92', NULL, 'Castlevania: Symphony of the Night', '1997-03-20', 9.0),
	(10, 2, 'D102', NULL, 'Devil Dice', '1998-06-18', 6.0),
	(11, 2, 'H112', 75.00, 'Hercs Adventures', '1997-07-31', 8.0),
	(12, 2, 'M122', 21.00, 'Myst', '1995-01-07', 4.0),
	(13, 3, 'W133', 39.99, 'Wario Land 4', '2001-08-21', 9.0),
	(14, 3, 'A143', 15.00, 'Advance Wars', '2001-09-09', 7.0),
	(15, 3, 'L153', NULL, 'LEGO Soccer Mania', '2002-06-21', 5.0),
	(16, 4, 'T164', 53.99, 'Theatrhythm Final Bar Line', '2023-02-15', 9.0),
	(17, 4, 'S174', 59.99, 'Super Mario Odyssey', '2017-10-27', 9.0),
	(18, 4, 'K184', 59.99, 'Kirby and the Forgotten Land', '2022-03-25', 9.0),
	(19, 4, 'P194', 59.99, 'Paper Mario: The Origami King', '2020-07-17', 8.0),
	(20, 6, 'M206', 39.95, 'Myst', '2007-12-07', 6.0),
	(21, 6, 'B216', NULL, 'Brain Age', '2005-05-19', 6.0),
	(22, 6, 'F226', NULL, 'Final Fantasy Tactics A2', '2007-10-25', 7.0),
	(23, 7, 'H237', 20.00, 'Halo 3', '2007-09-25', 9.0),
	(24, 8, 'M248', 5.00, 'Myst', '2012-03-27', 1.0);

INSERT INTO GenresVideogames(idVideogame, idGenre) VALUES
	(1, 1), (1, 7),
	(2, 1), (2, 7),
	(3, 1), (3, 7),
	(4, 1), (4, 7),
	(5, 1), (5, 7),
	(6, 1), (6, 7),
	(7, 3),
	(8, 3),
	(9, 3), (9, 6),
	(11, 4),
	(12, 1), (12, 7),
	(13, 3), (13, 7),
	(14, 8),
	(17, 3), (17, 4),
	(18, 3), (18, 4),
	(19, 4), (19, 6),
	(20, 1), (20, 7),
	(21, 7),
	(22, 6), (22, 8),
	(23, 2),
	(24, 1), (24, 7);

INSERT INTO UsersVideogames (idUser, idVideogame) VALUES
	(1, 7), (1, 23), (1, 21),
	(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 8), (2, 11), (2, 19), (2, 16),
	(3, 5), (3, 15),
	(4, 9), (4, 10), (4, 22);

INSERT INTO Reviews (idUser, idVideogame, reviewText, rating) VALUES
    (1, 7, 'Un clásico de plataformas que nunca pasa de moda.', 9.0),
    (1, 23, 'Increíble juego, una obra maestra en su tiempo.', 8.0),
    (2, 1, 'Demasiado Fácil.', 9.9),
    (2, 16, 'Algunas canciones muy cortas, demasiadas como DLC.', 7.0),
    (3, 5, 'Un juego que revolucionó el género de aventura gráfica.', 8.0),
    (4, 22, 'Un gran juego de estrategia por turnos. Muy recomendable.', 7.5),
    (4, 9, 'Gran ambiente, pero muy fácil.', 4.0);

INSERT INTO Achievements (idVideogame, title, description, points) VALUES
    (1, 'Completado', 'Completa el juego.', 100),
    (1, 'Primer fragmento', 'Descubre el primer fragmento del medallón.', 10),
    (23, 'Victoria en el modo campaña', 'Completa el modo campaña en cualquier dificultad.', 15),
    (18, 'Rescate de amigos', 'Encuentra y rescata a todos los amigos de Kirby.', 25),
    (13, 'Maestro del juego', 'Completa todos los niveles sin ayuda.', 30),
    (16, 'Experto en ritmo', 'Alcanza el 100% de precisión en todas las canciones.', 50),
    (22, 'Maestro táctico', 'Termina la campaña sin perder ninguna batalla.', 30);

INSERT INTO UsersAchievements (idUser, idAchievement, achievementDate) VALUES
    (1, 1, '2023-08-14 10:23:00'),
    (1, 2, '2023-08-15 12:45:00'),
    (2, 3, '2022-11-01 15:34:00'),
    (2, 4, '2022-11-05 17:00:00'),
    (3, 5, '2023-01-21 19:11:00'),
    (4, 6, '2023-02-10 08:22:00'),
    (4, 7, '2023-03-14 13:00:00');

INSERT INTO Friendships (idUser1, idUser2, friendshipDate) VALUES
    (1, 2, '2023-05-21 09:15:00'),
    (1, 3, '2023-06-01 14:20:00'),
    (2, 4, '2023-07-11 11:30:00'),
    (3, 4, '2023-08-02 16:40:00'),
    (3, 2, '2023-09-10 10:10:00'),
    (4, 1, '2023-10-05 13:25:00');



--Cree una consulta SQL que devuelva el precio máximo de videojuegos con valoración de 9.
SELECT MAX(price) AS max_price
FROM Videogames
WHERE score = 9;

--Cree un TRIGGER que evite insertar amistades duplicadas entre usuarios (1-2 y 2-1).

DELIMITER //
CREATE OR REPLACE TRIGGER prevent_duplicate_friendships
BEFORE INSERT ON Friendships
FOR EACH ROW
BEGIN 
 DECLARE friendship_exists INT;
    SELECT COUNT(*) INTO friendship_exists
    FROM Friendships
    WHERE (idUser1 = NEW.idUser1 AND idUser2 = NEW.idUser2) OR (idUser1 = NEW.idUser2 AND idUser2 = NEW.idUser1);
    IF friendship_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La amistad ya existe entre estos usuarios.';
    END IF;
END//
DELIMITER ;


--Cree una función que, dado un videojuego y puntuación, devuelva cuántas reseñas tienen ese rating exacto. Pruébela.

DELIMITER //
CREATE OR REPLACE FUNCTION count_reviews_by_rating(videogame_id INT, rating DECIMAL(4,2))
RETURNS INT
BEGIN
    DECLARE review_count INT;
    SELECT COUNT(*) INTO review_count
    FROM Reviews
    WHERE idVideogame = videogame_id AND rating = rating;
    RETURN review_count;
END//
DELIMITER ;

--  Cree una consulta que devuelva la valoración máxima por año de los videojuegos, ordenada por puntuación de mayor a menor.

SELECT YEAR(releaseDate) AS year, MAX(score) AS max_score
FROM Videogames
GROUP BY YEAR(releaseDate)
ORDER BY max_score DESC;


-- Crea una consulta que muestre el título del videojuego y el título de cada artículo publicado sobre él.

SELECT v.titular AS videojuego_title, a.titular AS article_title
FROM  Videogames v
JOIN Articulos a ON v.idVideojuego = a.idVideojuego
WHERE a.palabras > 500
ORDER BY v.titular, a.titular;


-- Muestra cuántos artículos se han publicado por videojuego.

SELECT  v.name AS Videogames,count(a.idArticulo) AS num_articulos 
FROM Videogames v
LEFT JOIN Articulos a ON v.idVideogame= a.idVideojuego
GROUP BY v.idVideogame , v.name ;

-- Obtén los videojuegos que tienen más de un artículo publicado en diferentes fechas.
SELECT A.idVideojuego, v.titular AS videojuego_title, COUNT(a.idArticulo) AS num_articulos
FROM Articulos a
Join Videogames v ON a.idVideojuego = v.idVideogame
GROUP BY A.idVideojuego, v.titular 
HAVING COUNT(DISTINCT a.fechaPublicacion) > 1;

-- Muestra el artículo más reciente publicado por cada videojuego.

SELECT a.idArticulo, a.titulo, a.fechaPublicacion, a.idVideojuego, v.titular AS videojuego
FROM Articulos a
JOIN Videogames v ON a.idVideojuego = v.idVideogame
WHERE (a.idArticulo, a.fechaPublicacion) IN (
  SELECT idArticulo, MAX(fechaPublicacion)
  FROM Articulos
  GROUP BY idVideojuego
);

--

-- 1. Muestra todas las amistades registradas, con los nombres de ambos usuarios.

SELECT 
  u1.username AS Usuario1,
  u2.username AS Usuario2
FROM Friendships f
JOIN Users u1 ON f.idUser1 = u1.idUser
JOIN Users u2 ON f.idUser2 = u2.idUser;


--2. Muestra todos los usuarios y cuántos amigos tienen.ç

SELECT 
  u.name AS Usuario,
  COUNT(f.idFriendship) AS NumeroDeAmigos
FROM Users u
LEFT JOIN Friendships f ON u.idUser = f.idUser1 OR u.idUser = f.idUser2
GROUP BY u.idUser, u.name
ORDER BY NumeroDeAmigos DESC;


--3. Encuentra los pares de usuarios que son mutuamente amigos.(Es decir, si (A → B) y (B → A) existen).

SELECT 
  u1.username AS Usuario1,
  u2.username AS Usuario2
FROM Friendships f1
JOIN Friendships f2 
  ON f1.idUser1 = f2.idUser2 AND f1.idUser2 = f2.idUser1
JOIN Users u1 ON u1.idUser = f1.idUser1
JOIN Users u2 ON u2.idUser = f1.idUser2
WHERE f1.idUser1 < f1.idUser2;


-- 4. ¿Qué usuarios no tienen amigos?
SELECT 
  u.name AS Usuario
FROM Users u
LEFT JOIN Friendships f ON u.idUser = f.idUser1 OR u.idUser = f.idUser2
WHERE f.idFriendship IS NULL;


--5. Inserta una nueva amistad (evitando duplicados inversos)
INSERT INTO Friendships (idUser1, idUser2)
SELECT 1, 3
WHERE NOT EXISTS (
  SELECT 1 FROM Friendships 
  WHERE (idUser1 = 1 AND idUser2 = 3) 
     OR (idUser1 = 3 AND idUser2 = 1)
);
