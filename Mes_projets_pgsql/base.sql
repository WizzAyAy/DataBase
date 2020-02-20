drop table if exists produit;
drop table if exists produit2;
/*
CREATE TABLE produit2
(
    numprod INT PRIMARY KEY NOT NULL,
    designation VARCHAR(100),
    prix INT
);

CREATE TABLE produit
(
    numprod INT PRIMARY KEY NOT NULL,
    designation VARCHAR(100),
    prix INT
);

INSERT INTO produit VALUES 
(1, 'clavier', NULL),
(2, 'souris', 70),
(3, 'ecran', 250),
(4, 'tour', 900),
(5, 'tapis', 40);

DROP FUNCTION toEuro();
CREATE FUNCTION toEuro() RETURNS void AS
$$
DECLARE
	e CURSOR for SELECT * FROM produit;
BEGIN
	IF(exists(select * from produit)) 
	THEN
		for i in e
		LOOP
			IF(i.prix is NULL) 
			THEN
				insert into produit2 values (i.numprod, UPPER(i.designation),0);
			ELSE	
				insert into produit2 values (i.numprod, UPPER(i.designation), i.prix / 7);
			END IF;		
		END LOOP; 
	ELSE 	
		insert into produit2 values (0, 'pas de produit', NULL);
	END IF;	
END;
$$ LANGUAGE 'plpgsql';


SELECT toEuro();
select * from produit;
select * from produit2;*/


drop table if exists avion;
drop table if exists pilote;
drop table if exists vol;
drop table if exists voltest;

CREATE TABLE avion
(
    avnum INT PRIMARY KEY NOT NULL,
    avnom VARCHAR(100),
    capacite INT,
    localisation VARCHAR(100)
);
INSERT INTO avion VALUES
(1,'A300',500,'paris'),
(2,'A310',550,'toulouse'),
(3,'A320',570,'bordeaux'),
(4,'A300',500,'angers'),
(5,'A320',570,'nantes'),
(6,'A320',570,'amiens'),
(7,'A320',570,'le mans'),
(8,'A310',500,'le havre');

select * from avion;

CREATE TABLE pilote
(
    pinum INT PRIMARY KEY NOT NULL,
    pinom VARCHAR(100),
    piprenom VARCHAR(100),
    ville VARCHAR(100),
    salaire INT
);

INSERT INTO pilote VALUES
(1,'maignan','quentin','angers',5000),
(2,'trem','guillaum','paris',7500),
(3,'lafargue','christ','jerusalem',1800),
(4,'davido','david','mars',9999999);

select * from pilote;

CREATE TABLE vol
(
    volnum INT PRIMARY KEY NOT NULL,
    pinum INT,
    avnum INT,
    villeDep VARCHAR(100),
    villeArr VARCHAR(100),
    heureDep INT,
    heureArr INT
);

CREATE TABLE voltest
(
    volnum INT PRIMARY KEY NOT NULL,
    pinum INT,
    avnum INT,
    villeDep VARCHAR(100),
    villeArr VARCHAR(100),
    heureDep INT,
    heureArr INT
);

INSERT INTO vol VALUES 
(400,1,1,'paris','rennes',12,20),
(401,2,2,'toulouse','marseille',6,15),
(402,3,4,'angers','le tholy',15,22),
(403,4,8,'constructeur','implicite',12,21);

select * from vol;

DROP FUNCTION MAJtime();
CREATE FUNCTION MAJtime() RETURNS void AS
$$
DECLARE
	avionA300 CURSOR for SELECT * FROM
	vol as Vo join avion as Av on Av.avnum = Vo.avnum where Av.avnom = 'A300';
	tempsA300 INT;	
	
	avionA310 CURSOR for SELECT * FROM
	vol as Vo join avion as Av on Av.avnum = Vo.avnum where Av.avnom = 'A310';
	tempsA310 INT;	
BEGIN
		for i in avionA300
		LOOP
		tempsA300 := (i.heureArr - i.heureDep) * 0.90 + i.heureDep;
		raise notice 'temps = %', tempsA300; 
insert into voltest values 
(i.volnum, i.pinum, i.avnum, i.villeDep ,i.villeArr, i.heureDep, tempsA300 );
		END LOOP; 
		
		for i in avionA310
		LOOP
		tempsA310 := (i.heureArr - i.heureDep) * 0.85 + i.heureDep;
		raise notice 'temps = %', tempsA310; 
insert into voltest values 
(i.volnum, i.pinum, i.avnum, i.villeDep ,i.villeArr, i.heureDep, tempsA310 );
		END LOOP;

END;
$$ LANGUAGE 'plpgsql';

select MAJtime();
select * from voltest;
