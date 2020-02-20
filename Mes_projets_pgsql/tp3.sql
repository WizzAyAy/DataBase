drop table if exists matiere CASCADE;
drop table if exists formation CASCADE;
drop table if exists etudiant CASCADE;
drop table if exists enseignant CASCADE;
drop table if exists tabnote CASCADE;
drop table if exists stat_resultat CASCADE;
--question1--
CREATE TABLE etudiant
(
    numet INT PRIMARY KEY NOT NULL,
    nom VARCHAR(100),
    prenom VARCHAR(100)
);
--\d etudiant;

CREATE TABLE enseignant
(
    numens INT PRIMARY KEY NOT NULL,
    nomens VARCHAR(100),
    prenomens VARCHAR(100)
);
--\d enseignant;

CREATE TABLE formation
(
    nomform VARCHAR(100) PRIMARY KEY NOT NULL,
    nbretud int,
    enseignantresponsable int
);
--\d formation;

CREATE TABLE matiere
(
    nommat VARCHAR(100),
    nomform VARCHAR(100),
    numens int,
    coef int,
    primary key (nommat,nomform),
    FOREIGN KEY (numens) REFERENCES enseignant (numens)
);
--\d matiere;

CREATE TABLE tabnote
(
    numetud int,
    nommat varchar(100),
    nomform varchar(100),
    note int,
    primary key (numetud, nommat, nomform)   
);
--\d tabnote;

CREATE TABLE stat_resultat
(
    nomformation VARCHAR(100),
    moygeneral int,
    nbrrecu int,
    nbretdpres int,
    notemax int,
    notemin int
);
\d stat_resultat;

insert into etudiant values 
	(1,'quentin',	'maignan'),
	(2,'christophe','lafargue'),
	(3,'guillaume',	'trem'),
	(4,'tki',	'toua'),
	(5,'toto',	'bien'),
	(6,'pourquoi',	'pas');
--select * from etudiant;

insert into enseignant values
	(1,'davido','davide'),
	(2,'erico','eric'),
	(3,'igoat','stephen'),
	
	(4,'t ki','touAA'),
	(5,'claude','loupgarrou'),
	(6,'chef','alit'),
	
	(7,'ali','baba'),
	(8,'alo','nabila'),
	(9,'koba','kobe');
--select * from enseignant;

insert into formation values
	('L1',2,1),
	('L2',2,4),
	('L3',2,7);
--select * from formation;

insert into matiere values
	('cours de c++',	'L1',1,6),
	('fondement',		'L1',2,5),
	('systeme d image',	'L1',3,3),
	('cours de c++ 2',	'L2',4,6),
	('graphes', 		'L2',5,5),
	('ocaml',       	'L2',6,3),
	('cours de c++ 3',	'L3',7,6),
	('intelligence art','L3',8,5),
	('base de donnée',	'L3',9,3);
--select * from matiere;
	
insert into tabnote values
	(1,'cours de c++',		'L1', 20),
	(1,'fondement',	  		'L1', 12),
	(1,'systeme d image',	'L1', 10),
	(2,'cours de c++',		'L1', 8),
	(2,'fondement',	  		'L1', 12),
	(2,'systeme d image',	'L1', 13),
	
	(3,'cours de c++ 2',	'L2', 12),
	(3,'graphe',			'L2', 18),
	(3,'ocaml',				'L2', 5),
	(4,'cours de c++ 2',	'L2', 7),
	(4,'graphe',			'L2', 15),
	(4,'ocaml',	 			'L2', 13),
	
	(5,'cours de c++ 3',	'L3', 8.5),
	(5,'intelligence art',	'L3', 20),
	(5,'base de donnée',	'L3', 17),
	(6,'cours de c++ 3',	'L3', 12),
	(6,'intelligence art',	'L3', 8),
	(6,'base de donnée',	'L3', 15);
--select * from tabnote;



--question2--
DROP FUNCTION if exists moyNote();
CREATE FUNCTION moyNote() RETURNS float AS
$$
DECLARE
	NoteCurs CURSOR for SELECT note, coef FROM tabnote as t natural join matiere as m;
	totnote int;
	nbnote int;	
	moy float;
BEGIN

		totnote := 0;
		nbnote := 0;
		for i in NoteCurs
		LOOP
			totnote = i.note * i.coef + totnote;
			nbnote = i.coef + nbnote; 
		END LOOP; 
			moy = totnote / nbnote;
			return moy;	

END;
$$ LANGUAGE 'plpgsql';

--question3--
select e.nom, e.prenom, t.nommat, t.note 
from etudiant as e join tabnote t on e.numet = t.numetud 
where t.note > moyNote();



--question4--
DROP FUNCTION if exists moyNote_formation(forma VARCHAR(100));
CREATE FUNCTION moyNote_formation(forma VARCHAR(100)) RETURNS float AS
$$
DECLARE
	NoteCurs CURSOR for SELECT * FROM tabnote as t 
	natural join formation as f 
	natural join matiere as m 
	where nomform=forma;
	
	totnote int;
	nbnote int;	
	moy float;
BEGIN
		totnote := 0;
		nbnote := 0;
		for i in NoteCurs
		LOOP
			totnote = i.note * i.coef + totnote;
			nbnote = i.coef + nbnote; 
		END LOOP; 
			moy = totnote / nbnote;
			return moy;		

END;
$$ LANGUAGE 'plpgsql';

--question5--
DROP FUNCTION if exists stat_form();
CREATE FUNCTION stat_form() RETURNS void AS
$$
DECLARE
	curs_formation cursor for SELECT * FROM formation f;
	nmin int;
	nmax int;
	nbrecu int;
BEGIN
	for i in curs_formation
		LOOP         
		nmin :=(select min(note) from tabnote where nomform = i.nomform);
		nmax :=(select max(note) from tabnote where nomform = i.nomform);
		
				insert into stat_resultat values
				(i.nomform, moyNote_formation(i.nomform),0, i.nbretud, nmax, nmin);
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
	curs CURSOR for SELECT t.nommat, t.nomform 
	FROM etudiant as e 
	join tabnote as t on t.numetud = e.numet
	where numet=num;
BEGIN

	for i in curs
	LOOP
		return next i.nomform;
		return next i.nommat;
	END LOOP;
		
	return;
END;
$$ LANGUAGE 'plpgsql';

select suivipar(2);


--question7--
DROP FUNCTION if exists collegue(num int);
CREATE FUNCTION collegue(num int) RETURNS setof text AS
$$
DECLARE
		curs CURSOR for 
		
		SELECT *
		from enseignant e join
		matiere m on e.numens = m.numens
		where nomform in(
			SELECT m.nomform
			from enseignant e join
			matiere m on e.numens = m.numens
			where e.numens = num);
BEGIN
	for i in curs
	LOOP
		if(i.numens != num) then 
		return next i.nomens;
		return next i.prenomens;
		end if;	
	END LOOP;
	return;
END;
$$ LANGUAGE 'plpgsql';

select collegue(1);

