DROP TABLE IF EXISTS eleveur CASCADE; 
DROP TABLE IF EXISTS elevage CASCADE; 
DROP TABLE IF EXISTS adresse CASCADE; 

DROP TYPE IF EXISTS t_elevage CASCADE; 
DROP TYPE IF EXISTS t_adresse CASCADE; 

CREATE TYPE t_elevage AS (
	animal varchar(30),
	ageMin int,
	nbrMax int
);
CREATE TABLE elevage OF t_elevage; 

CREATE TYPE t_adresse AS (
	nrue int,
	rue varchar(30),
	ville varchar(30),
	code_postal int
);
CREATE TABLE adresse OF t_adresse; 

CREATE TABLE eleveur(
	numli int,
	elevage t_elevage,
	adresse t_adresse
);

INSERT INTO elevage VALUES
	('ovin',18,150),
	('porcin',12,180),
	('volaille',12,280);
SELECT * FROM elevage;

	
INSERT INTO adresse VALUES
	(1, 'boulevard foch', 'Angers', 49100),
	(45, 'rue de la ferme', 'Rennes', 78000),
	(98, 'rue jean', 'Paris', 75000);
SELECT * FROM adresse;

INSERT INTO eleveur VALUES
	(3, (SELECT e FROM elevage e WHERE animal='volaille'), (SELECT a FROM adresse a WHERE ville='Angers')),
	(2, (SELECT e FROM elevage e WHERE animal='porcin'), (SELECT a FROM adresse a WHERE ville='Paris'));
SELECT * FROM eleveur;

--QUESTION4--
DROP FUNCTION if exists changerAdr();
CREATE FUNCTION changerAdr() RETURNS void as
$$	
BEGIN
	UPDATE eleveur e
		SET	adresse.ville='Bordeaux',
			adresse.code_postal=33000
			where (e.elevage).animal='ovin';
	return;
END;
$$ LANGUAGE 'plpgsql';

select changerAdr();
select * from eleveur;

--QUESTION5--
DROP FUNCTION if exists test();
CREATE FUNCTION test() RETURNS TRIGGER as
$$	
BEGIN
	IF ( (new.adresse).ville != 'Paris' )
	then return new;
	else return null;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER climatiqueTrigger BEFORE INSERT
ON eleveur FOR EACH ROW
EXECUTE PROCEDURE test();

INSERT INTO eleveur VALUES
	(1, (SELECT e FROM elevage e WHERE animal='volaille'), (SELECT a FROM adresse a WHERE ville='Paris'));
SELECT * FROM eleveur;


--QUESTION6--
DROP FUNCTION if exists test2();
CREATE FUNCTION test2() RETURNS TRIGGER as
$$	
BEGIN
	UPDATE eleveur e 
	SET elevage = (SELECT e FROM elevage e WHERE animal='volaille')
	WHERE (e.adresse).ville='Angers';

	IF ( (new.elevage).animal != 'volaille' AND (new.adresse).ville = 'Angers' )
		then return null;
		else return new;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER volailleTrigger BEFORE INSERT
ON eleveur FOR EACH ROW
EXECUTE PROCEDURE test2();

INSERT INTO eleveur VALUES
	(1, (SELECT e FROM elevage e WHERE animal='volaille'), (SELECT a FROM adresse a WHERE ville='Paris'));
SELECT * FROM eleveur;















