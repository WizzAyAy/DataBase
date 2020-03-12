drop table if exists stat_resultat CASCADE;
drop table if exists tabnote CASCADE;
drop table if exists matiere CASCADE;
drop table if exists formation CASCADE;
drop table if exists enseignant CASCADE;
drop table if exists etudiant CASCADE;

drop type if exists t_stat_resultat CASCADE;
drop type if exists t_tabnote CASCADE;
drop type if exists t_matiere CASCADE;
drop type if exists t_formation CASCADE;
drop type if exists t_enseignant CASCADE;
drop type if exists t_etudiant CASCADE;

create type t_etudiant as(
	numet int,
	nom varchar(30),
	prenom varchar(30)
);

create type t_enseignant as(
	numens int,
	nomens varchar(30),
	prenomens varchar(30)
);

create type t_formation as(
	nomform varchar(30),
	nbretud int,
	ensrep t_enseignant
);

create type t_matiere as(
	nommat varchar(30),
	format t_formation,
	numens int,
	coef int
);

create type t_tabnote as(
	etudiant t_etudiant,
	matiere t_matiere,
	note float
);

create type t_stat_resultat as(
	forma t_formation,
	moy_general float,
	nbrrecu int,
	nbretdpres int,
	notemax float,
	notemin float
);

create table etudiant of t_etudiant;
create table enseignant of t_enseignant;
create table formation of t_formation;
create table matiere of t_matiere;
create table tabnote of t_tabnote;
create table stat_resultat of t_stat_resultat;

insert into etudiant values 
	(1,'quentin',	'maignan'),
	(2,'christophe','lafargue'),
	(3,'guillaume',	'trem'),
	(4,'tki',	'toua'),
	(5,'toto',	'bien'),
	(6,'pourquoi',	'pas');
-- ~ select * from etudiant;

insert into enseignant values
	(1,'davido','davide'),
	(2,'erico','eric'),
	(3,'igoat','stephen'),
	
	(4,'leprof','demaths'),
	(5,'claude','loupgarrou'),
	(6,'chef','alit'),
	
	(7,'ali','baba'),
	(8,'alo','nabila'),
	(9,'koba','kobe');
-- ~ select * from enseignant;

insert into formation values
	('L1',2, (SELECT e FROM enseignant e WHERE numens=1)),
	('L2',2, (SELECT e FROM enseignant e WHERE numens=2)),
	('L3',2, (SELECT e FROM enseignant e WHERE numens=3));
-- ~ select * from formation;


insert into matiere values
	('cours de c++',	(SELECT f FROM formation f WHERE nomform='L1'),1,6),
	('fondement',		(SELECT f FROM formation f WHERE nomform='L1'),2,5),
	('systeme d image',	(SELECT f FROM formation f WHERE nomform='L1'),3,3),
	('cours de c++ 2',	(SELECT f FROM formation f WHERE nomform='L2'),4,6),
	('graphes', 		(SELECT f FROM formation f WHERE nomform='L2'),5,5),
	('ocaml',       	(SELECT f FROM formation f WHERE nomform='L2'),6,3),
	('cours de c++ 3',	(SELECT f FROM formation f WHERE nomform='L3'),7,6),
	('intelligence art',(SELECT f FROM formation f WHERE nomform='L3'),8,5),
	('base de donnée',	(SELECT f FROM formation f WHERE nomform='L3'),9,3);
-- ~ select * from matiere;


insert into tabnote values
	((SELECT e FROM etudiant e WHERE numet=1), (SELECT m FROM matiere m WHERE nommat='cours de c++'), 20),
	((SELECT e FROM etudiant e WHERE numet=1), (SELECT m FROM matiere m WHERE nommat='fondement'), 14),
	((SELECT e FROM etudiant e WHERE numet=1), (SELECT m FROM matiere m WHERE nommat='systeme d image'), 10),
	
	((SELECT e FROM etudiant e WHERE numet=2), (SELECT m FROM matiere m WHERE nommat='cours de c++'), 12),
	((SELECT e FROM etudiant e WHERE numet=2), (SELECT m FROM matiere m WHERE nommat='fondement'), 3),
	((SELECT e FROM etudiant e WHERE numet=2), (SELECT m FROM matiere m WHERE nommat='systeme d image'), 9),
	
	((SELECT e FROM etudiant e WHERE numet=3), (SELECT m FROM matiere m WHERE nommat='cours de c++ 2'), 15),
	((SELECT e FROM etudiant e WHERE numet=3), (SELECT m FROM matiere m WHERE nommat='graphes'), 17),
	((SELECT e FROM etudiant e WHERE numet=3), (SELECT m FROM matiere m WHERE nommat='ocaml'), 7),
	
	((SELECT e FROM etudiant e WHERE numet=4), (SELECT m FROM matiere m WHERE nommat='cours de c++ 2'), 12),
	((SELECT e FROM etudiant e WHERE numet=4), (SELECT m FROM matiere m WHERE nommat='graphes'), 19),
	((SELECT e FROM etudiant e WHERE numet=4), (SELECT m FROM matiere m WHERE nommat='ocaml'), 9),
	
	((SELECT e FROM etudiant e WHERE numet=5), (SELECT m FROM matiere m WHERE nommat='cours de c++ 3'), 7),
	((SELECT e FROM etudiant e WHERE numet=5), (SELECT m FROM matiere m WHERE nommat='intelligence art'), 3),
	((SELECT e FROM etudiant e WHERE numet=5), (SELECT m FROM matiere m WHERE nommat='base de donnée'), 13),
	
	((SELECT e FROM etudiant e WHERE numet=6), (SELECT m FROM matiere m WHERE nommat='cours de c++ 3'), 18),
	((SELECT e FROM etudiant e WHERE numet=6), (SELECT m FROM matiere m WHERE nommat='intelligence art'), 2),
	((SELECT e FROM etudiant e WHERE numet=6), (SELECT m FROM matiere m WHERE nommat='base de donnée'), 12);

-- ~ select * from tabnote;

--question2--
DROP FUNCTION if exists moyNote();
CREATE FUNCTION moyNote() RETURNS float AS
$$
DECLARE
	NoteCurs CURSOR for SELECT note, matiere FROM tabnote;
	totnote int;
	nbnote int;	
	moy float;
BEGIN
		totnote := 0;
		nbnote := 0;
		for i in NoteCurs
		LOOP
			totnote = i.note * (i.matiere).coef + totnote;
			nbnote = (i.matiere).coef + nbnote; 
		END LOOP; 
			moy = totnote / nbnote;
			return moy;	

END;
$$ LANGUAGE 'plpgsql';

select moyNote();

--question3--
select t.note, t.etudiant 
from tabnote t
where t.note > moyNote();

--question4--
DROP FUNCTION if exists moyNote_formation(forma varchar(30));
CREATE FUNCTION moyNote_formation(forma varchar(30)) RETURNS float AS
$$
DECLARE
	NoteCurs CURSOR for SELECT * FROM tabnote t
	where ((t.matiere).format).nomform=forma;
	
	totnote int;
	nbnote int;	
	moy float;
BEGIN
		totnote := 0;
		nbnote := 0;
		for i in NoteCurs
		LOOP
			totnote = i.note * (i.matiere).coef + totnote;
			nbnote = (i.matiere).coef + nbnote; 
		END LOOP;
		IF (nbnote != 0)
		THEN 
			moy = totnote / nbnote;
			return moy;	
		ELSE 
			raise notice 'cette formation n existe pas'; 
			return 0;
		END IF;

END;
$$ LANGUAGE 'plpgsql';
select moyNote_formation('L1');


--question5--
DROP FUNCTION if exists stat_form();
CREATE FUNCTION stat_form() RETURNS void AS
$$
DECLARE
	curs_formation CURSOR for select * from formation f;
	forma t_formation;
BEGIN
	for i in curs_formation
		LOOP
		select into forma * from formation where nomform = i.nomform;
		        
				insert into stat_resultat values
				(forma, moyNote_formation(i.nomform));
		END LOOP; 
END;
$$ LANGUAGE 'plpgsql';

select stat_form();
select * from stat_resultat;

--question6--
DROP FUNCTION if exists suivipar(num int);
CREATE FUNCTION suivipar(num int) RETURNS setof text AS
$$
DECLARE
	curs CURSOR for SELECT * from tabnote t where (t.etudiant).numet = num;
	b boolean;
BEGIN
	b := true;
	for i in curs
	LOOP
		if (b) then 
			return next i.etudiant;
			b = false;
		end if;	
		return next i.matiere;
	END LOOP;
		
	return;
END;
$$ LANGUAGE 'plpgsql';

select suivipar(1);

--question7--
DROP FUNCTION if exists collegue(num int);
CREATE FUNCTION collegue(num int) RETURNS setof text AS
$$
DECLARE
		curs CURSOR for 
		
		SELECT *
		from enseignant e join
		matiere m on e.numens = m.numens
		where (m.format).nomform in(
			SELECT (m.format).nomform
			from enseignant e join
			matiere m on e.numens = m.numens
			where e.numens = num);
BEGIN
	for i in curs
	LOOP
		if(i.numens != num) then 
		return next (i.nomens, i.prenomens);
		end if;	
	END LOOP;
	return;
END;
$$ LANGUAGE 'plpgsql';

select collegue(2);











