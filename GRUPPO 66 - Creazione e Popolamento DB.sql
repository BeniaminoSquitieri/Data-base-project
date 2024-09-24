/*Cancellazione precauzionale di eventuali tabelle esistenti*/
DROP TABLE IF EXISTS Vittima CASCADE;
DROP TABLE IF EXISTS Attentato CASCADE;
DROP TABLE IF EXISTS Luogo CASCADE;
DROP TABLE IF EXISTS Collocazione CASCADE;
DROP TABLE IF EXISTS Associazione CASCADE;
DROP TABLE IF EXISTS Terrorista CASCADE;
DROP TABLE IF EXISTS Soprannome CASCADE;
DROP TABLE IF EXISTS Influenza CASCADE;
DROP TABLE IF EXISTS Organizzazione CASCADE;
DROP TABLE IF EXISTS Arma CASCADE;
DROP TABLE IF EXISTS Offensiva CASCADE;
DROP TABLE IF EXISTS Coinvolgimento CASCADE;
DROP DOMAIN IF EXISTS dateType;
DROP VIEW IF EXISTS attentatiConArmaDaFuoco CASCADE;
DROP VIEW IF EXISTS attentatiSenzaArmaDaFuoco CASCADE;
DROP VIEW IF EXISTS attentatiInEuropa CASCADE;
DROP VIEW IF EXISTS attentatiInAsia CASCADE;
DROP VIEW IF EXISTS attentatiInOceania CASCADE;
DROP VIEW IF EXISTS attentatiInAmerica CASCADE;
DROP VIEW IF EXISTS attentatiInAfrica CASCADE;
DROP VIEW IF EXISTS nomiOperazioniEuropa CASCADE;
DROP VIEW IF EXISTS nomiOperazioniAsia CASCADE;
DROP VIEW IF EXISTS nomiOperazioniAfrica CASCADE;
DROP VIEW IF EXISTS nomiOperazioniOceania CASCADE;
DROP VIEW IF EXISTS nomiOperazioniAmerica CASCADE;

/*Creazione dominio sulla data affinché questa sia minore o uguale di quella attuale*/
CREATE DOMAIN dateType AS
	date CHECK (VALUE<=NOW());

/*Creazione delle tabelle del Database*/
CREATE TABLE Terrorista(
	identificativo SERIAL,
	nome varchar(40) NOT NULL,
	cognome varchar(40) NOT NULL,
	dataDiNascita dateType NOT NULL,
	nazionalita varchar(40) NOT NULL,
	sesso varchar(10) NOT NULL,
	altezza integer,
	CONSTRAINT Pk_Terrorista PRIMARY KEY (identificativo),
	CONSTRAINT CheckSesso CHECK (sesso='Maschio' or sesso='Femmina'),
	CONSTRAINT CheckAltezza CHECK (altezza<'260' and altezza>'80')
);

CREATE TABLE Soprannome(
	appellativo varchar(40),
	terrorista integer,
	CONSTRAINT Pk_Soprannome PRIMARY KEY (appellativo),
	CONSTRAINT Fk_Soprannome_Terrorista FOREIGN KEY (terrorista) REFERENCES Terrorista(identificativo)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Attentato(
	codice SERIAL,
	dataAvvenimento dateType NOT NULL,
	descrizione varchar(350) NOT NULL,
	tipologia varchar(30) NOT NULL,
	obiettivo varchar(50) NOT NULL,
	numeroVittime integer DEFAULT 0,
	nomeOperazione varchar(30) UNIQUE NOT NULL,
	capo integer,
	CONSTRAINT Pk_Attentato PRIMARY KEY (codice),
	CONSTRAINT Fk_Attentato_Terrorista FOREIGN KEY (capo) REFERENCES Terrorista(identificativo)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT CheckNumeroVittime CHECK (numeroVittime>='0')
);

CREATE TABLE Associazione(
	attentatoPadre integer,
	attentatoDerivato integer,
	descrizione varchar(350) NOT NULL,
	CONSTRAINT Pk_Associazione PRIMARY KEY (attentatoPadre, attentatoDerivato),
	CONSTRAINT Fk_Associazione_AttentatoPadre FOREIGN KEY (attentatoPadre) REFERENCES Attentato(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Associazione_AttentatoDerivato FOREIGN KEY (attentatoDerivato) REFERENCES Attentato(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Vittima(
	codice SERIAL,
	nome varchar(40),
	cognome varchar(40),
	dataDiNascita dateType,
	nazionalita varchar(40),
	CONSTRAINT Pk_Vittima PRIMARY KEY (codice)
);

CREATE TABLE Coinvolgimento(
	vittima integer,
	attentato integer,
	condizione varchar(8),
	CONSTRAINT Pk_Coinvolgimento PRIMARY KEY (vittima, attentato),
	CONSTRAINT Fk_Coinvolgimento_Vittima FOREIGN KEY (vittima) REFERENCES Vittima(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Coinvolgimento_Attentato FOREIGN KEY (attentato) REFERENCES Attentato(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT CheckCondizione CHECK (condizione='Morto' or condizione='Ferito' or condizione='Illeso')
);

CREATE TABLE Luogo(
	coordinate varchar(40),
	continente varchar(20) NOT NULL,
	nazione varchar(50) NOT NULL,
	citta varchar(58) NOT NULL,
	CONSTRAINT Pk_Luogo PRIMARY KEY (coordinate),
	CONSTRAINT CheckContinente CHECK(continente='Europa' or continente='Africa' or continente='Asia' or continente='Oceania' or continente='America')
);

CREATE TABLE Collocazione(
	luogo varchar(40),
	attentato integer,
	CONSTRAINT Pk_Collocazione PRIMARY KEY (luogo, attentato),
	CONSTRAINT Fk_Collocazione_Luogo FOREIGN KEY (luogo) REFERENCES Luogo(coordinate)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Collocazione_Attentato FOREIGN KEY (attentato) REFERENCES Attentato(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Arma(
	nome varchar(50),
	tipo varchar(20) NOT NULL,
	descrizione varchar(350) NOT NULL,
	CONSTRAINT Pk_Arma PRIMARY KEY (nome)
);

CREATE TABLE Offensiva(
	terrorista integer,
	arma varchar(50),
	attentato integer,
	CONSTRAINT Pk_Offensiva PRIMARY KEY (terrorista, arma, attentato),
	CONSTRAINT Fk_Offensiva_Terrorista FOREIGN KEY (terrorista) REFERENCES Terrorista(identificativo)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Offensiva_Arma FOREIGN KEY (arma) REFERENCES Arma(nome)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Offensiva_Attentato FOREIGN KEY (attentato) REFERENCES Attentato(codice)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Organizzazione(
	nomeGruppo varchar(50),
	fondazione dateType,
	numeroComponenti integer,
	tipo varchar(30) NOT NULL,
	dottrina varchar(50),
	orientamento varchar(50),
	nomeLeader varchar(40),
	cognomeLeader varchar(40),
	CONSTRAINT Pk_Organizzazione PRIMARY KEY (nomeGruppo)
);

CREATE TABLE Influenza(
	dataInizio dateType NOT NULL,
	terrorista integer,
	dataFine dateType,
	descrizione varchar(350),
	attuale boolean NOT NULL DEFAULT 'true',
	organizzazione varchar(50),
	CONSTRAINT Pk_Influenza PRIMARY KEY (dataInizio),
	CONSTRAINT Fk_Influenza_Organizzazione FOREIGN KEY (organizzazione) REFERENCES Organizzazione(nomeGruppo)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT Fk_Influenza_Terrorista FOREIGN KEY (terrorista) REFERENCES Terrorista(identificativo)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

/*Popolamento del Database*/
START TRANSACTION;
INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Is''ad', 'Baraka Mifsud', '11-02-1978', 'Arabia Saudita', 'Femmina', '159');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('40.773193, 14.796561','Europa','Italia','Fisciano');
INSERT INTO Arma(nome, tipo, descrizione)
  VALUES('Accuracy International AWM','Arma da Fuoco','Il Accuracy International AWM (Arctic Warfare Magnum) è un prodotto della Accuracy International.
		 È anche conosciuto come AWSM (Arctic Warfare Super Magnum), che tipicamente denota la versione .338 Lapua Magnum.
		 Al momento è molto usato in condizioni estreme perché resiste a temperature da -40 a +50 °C.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('31-12-2019', 'La criminale è entrata all''interno dell''Università con un fucile di precisione e ha cominciato a sparare
		   a vista. Panico tra gli studenti e il personale, l''intervento delle forze dell''ordine è stato tempestivo.', 'Assalto armato', 'Università', 'Attacco all''università', '1');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('1', 'Accuracy International AWM', '1');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('40.773193, 14.796561','1');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Jake R.','Reis','01-11-1992','USA');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Marco','Rossi','24-03-1998','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Troy M.','Young','10-04-2001','USA');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Lina.','Marino','01-11-2000','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Frediana','Marchesi','24-03-1998','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Azas','Samaniego Cervántez','10-04-1997','Spagna');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('1','1','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('2','1','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('3','1','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('4','1','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('5','1','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('6','1','Ferito');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Abeba', 'Yonatan', '30-08-1973', 'Eritrea', 'Femmina', '156');
INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Ali', 'Abaalom', '08-08-1987', 'Eritrea', 'Maschio', '177');
INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Adiam', 'Negassi', '29-06-1993', 'Eritrea', 'Femmina', '163');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('40.851775, 14.268124','Europa','Italia','Napoli');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('AK-47','Arma da Fuoco','L''AK-47 è un fucile d''assalto ideato e progettato in Unione Sovietica,
		 dotato di selettore di fuoco ed operato a gas, camerato originariamente per il proiettile 7,62 × 39 mm.');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('AEK-971','Arma da Fuoco','Il design e la meccanica dell''AEK sono basati sui vecchi fucili AK-47,
		 con una sensibilità e precisione maggiore di questi ultimi.');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Granata da fucile','Ordigno esplosivo','Una granata da fucile è una granata che usa un lanciatore attaccato ad un fucile
		 per permettere una distanza di tiro maggiore rispetto ad una semplice bomba a mano lanciata con la sola forza del braccio.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('11-07-2017', 'Assalitori hanno attaccato la strada cittadina principale e distrutto palazzi e veicolo situati in zona.', 'Assalto armato', 'Cittadini', 'Assalto di Napoli', '2');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('2', 'AEK-971', '2');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('3', 'AK-47', '2');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('3', 'Granata da fucile', '2');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('4', 'AEK-971', '2');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('40.851775, 14.268124','2');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Fernanda','Rodriguez','10-07-1986','Spagna');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Manuela','Cunha Carvalho','08-09-1943','Brasile');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('David','Labrie','30-03-1942','Francia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Grace','Wyatt','03-06-1962','Inghilterra');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Furio','Iadanza','09-03-1941','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Viola','Toscano','21-06-1981','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Iole','Sal','05-07-1953','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Ninfa','Barese','15-09-1998','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Rinaldo','Udinesi','14-12-1997','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Natalino','Genovesi','15-11-1987','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Renzo','Esposito','08-02-1965','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Marianna','Siciliani','18-06-1972','Italia');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('7','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('8','2','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('9','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('10','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('11','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('12','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('13','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('14','2','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('15','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('16','2','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('17','2','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('18','2','Ferito');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Katherine N.', 'Nations', '15-02-2001', 'USA', 'Femmina', '164');
INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Antonio M.', 'Autrey', '19-07-1974', 'USA', 'Maschio', '183');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('41.902783, 12.496365','Europa','Italia','Roma');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('AMT Backup','Arma da Fuoco','La AMT Backup è una pistola semiautomatica statunitense moderna.
		 Prodotta a partire dal 1976 dalla Ordnance Manufacturing Corporation di El Monte (California),
		 rilevata poi dalla Arcadia Machine & Tools, con sede dapprima a El Monte e successivamente al 1980
		 a Covina e oggi commercializzata dalla IAI di Irwindale');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('25-03-2018', 'Degli attentatori hanno iniziato a sparare sui civili in una piazza.', 'Assalto armato', 'Milizia non statale', 'Tragedia di Roma', '5');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('5', 'AMT Backup', '3');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('6', 'AMT Backup', '3');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('41.902783, 12.496365','3');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Sofia','Huhtala','05-03-2003','Finlandia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Fulvia','Li Fonti','17-12-1977','Italia');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('19','3','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('20','3','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Damian', 'Yevdokimov', '21-02-1993', 'Russia', 'Maschio', '186');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('45.465422, 9.185924','Europa','Italia','Milano');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Barrett M82','Arma da Fuoco','Si tratta di un fucile di precisione anti-materiale in calibro .50 BMG (12,7 × 99 mm NATO).
		 Grazie alla lunga gittata e la disponibilità di munizioni altamente efficaci (come API o Raufoss Mk 211).');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('27-12-2001', 'Sospetti ribelli hanno attaccato la città per sradicarne il Capitalismo che la compone.', 'Assalto armato', 'Cittadini', 'Impronta russa a Milano', '5');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('1', 'Barrett M82', '4');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('5', 'Barrett M82', '4');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('5', 'AMT Backup', '4');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('7', 'Barrett M82', '4');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('7', 'Granata da fucile', '4');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('45.465422, 9.185924','4');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Alexander','Wood','09-02-1999','Inghilterra');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Tatsuo','Kasai','26-04-1984','Giappone');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Abela','Fiorentino','17-02-1988','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Crescenzo','Moretti','16-12-1984','Italia');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('21','4','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('22','4','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('23','4','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('24','4','Ferito');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Butrus', 'Zahid Sabbagh', '20-08-1989', 'Arabia Saudita', 'Maschio', '171');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('52.520007, 13.404954','Europa','Germania','Berlino');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Bomba all''Orsini','Ordigno esplosivo','Una bomba all''Orsini è una bomba a mano a forma generalmente sferica che,
		 invece di utilizzare una miccia o un qualsiasi sistema a tempo per la sua attivazione, è circondata da una serie di
		 piccole capsule riempite di fulminato di mercurio.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('29-04-2009', 'Improvviso attacco ha ucciso e ferito delle persone in un quartiere sciita di Berlino.', 'Esplosione', 'Cittadini', 'Strage sciita', '8');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('8', 'Bomba all''Orsini', '5');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('52.520007, 13.404954','5');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Peter','Brauer','04-11-1971','Germania');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Marcus','Sule','28-12-1985','Germania');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Melt','Schmelzer','28-04-2001','Germania');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Natálie','Krejcarová','03-01-1963','Repubblica Ceca');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('25','5','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('26','5','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('27','5','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('28','5','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Asima', 'Sameera Antar', '01-05-1972', 'Arabia Saudita', 'Femmina', '166');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('48.856614, 2.352222','Europa','Francia','Parigi');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Beretta BM 59','Arma da Fuoco','Il Beretta BM 59 è un fucile da battaglia adottato ufficialmente dall''Esercito Italiano nel 1959.
		 È stata l''ultimo tipo di tale fucile ad esser adottato dalle forze italiane: la distribuzione ai reparti cominciò nel 1962
		 ed è stato sostituito dall''AR 70/90, sempre della Beretta, negli anni novanta.');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('MG 42','Arma da Fuoco','La MG 42 è una mitragliatrice calibro 7,92 mm Mauser sviluppata dall''industria bellica della Germania nazista e
		 entrata in servizio nel 1942.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('31-12-2019', 'Una rifugiata ha creato il panico al centro della città', 'Assalto armato', 'Cittadini', 'Paura a Parigi', '9');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('9', 'Beretta BM 59', '6');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('9', 'MG 42', '6');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('9', 'AEK-971', '6');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('48.856614, 2.352222','6');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Levi', 'Maddocks', '15-05-1985', 'Australia', 'Maschio', '185');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('40.712784, -74.005941','America','USA','New York');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Colt Navy','Arma da Fuoco','La Colt Navy è un''arma da fuoco corta calibro .36 ad avancarica del tamburo immessa sul mercato statunitense a partire dal 1850.
		È conosciuta anche come Colt mod. 1851, dall''anno in cui la distribuzione divenne effettiva.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('31-12-2019', 'Aggressore armato ha attaccato un club house di una comunità residenziale a New York, Stati Uniti. Un agente di sicurezza è stato preso in ostaggio e rilasciato più tardi quel giorno.', 'Attacco con ostaggio', 'Business', 'Attacco Club House', '10');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('10', 'Colt Navy', '7');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('40.712784, -74.005941','7');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Park', 'Chao', '20-07-1972', 'Cina', 'Maschio', '165');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('39.904200, 116.407396','Asia','Cina','Pechino');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Armsel Striker','Arma da Fuoco','L''Armsel Striker (con le varianti Sentinel Arms Co Striker-12, Protecta, Protecta Bulldog, e
		 Cobray/SWD Street Sweeper) è un fucile a canna liscia semiautomatico calibro 12 progettato per il controllo delle rivolte e
		 per il combattimento.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('21-12-2019', 'Un ex soldato ha attentato alla vita del colonnello Lim Son Jung nel distretto più famoso di Pechino.', 'Assassinio', 'Militare', 'Attacco a Lim Son Jung', '11');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('11', 'Armsel Striker', '8');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('39.904200, 116.407396','8');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Lim Son','Jung','28-09-1954','Cina');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('29','8','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Olisanugo', 'Uchenna', '19-06-1985', 'Nigeria', 'Femmina', '168');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('-25.746111, 28.188056','Africa','Sud Africa','Pretoria');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('FN Minimi','Arma da Fuoco','La FN Minimi è una mitragliatrice leggera calibro 5,56 × 45 mm NATO o 7,62 × 51 mm NATO
		 (versione MK3) prodotta dall''azienda belga Fabrique Nationale de Herstal.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('29-04-1996', 'Una donna nigeriana ha aperto il fuoco nel campo per sfollati interni (IDP) di Pretoria.', 'Attacco a infrastruttura', 'Internally Displace Person Camp', 'Pretoria nel caos', '12');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('12', 'FN Minimi', '9');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('-25.746111, 28.188056','9');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Maria','Cremonesi','30-05-1963','Italia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Chikezie','Igwebuike','04-05-1978','Repubblica Democratica del Congo');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Afamefuna','Chijioke','04-10-1955','Nigeria');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('30','9','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('31','9','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('32','9','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Ashraf', 'Yahyah Hajjar', '26-10-1996', 'Arabia Saudita', 'Maschio', '185');
INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Rachel', 'Jessop', '14-01-1990', 'Australia', 'Femmina', '175');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  VALUES('-35.282000, 149.128684','Oceania','Australia','Canberra');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Manganello','Arma bianca','Il manganello o sfollagente è un''arma contundente esclusivamente destinata all''offesa
		 in dotazione esclusiva delle forze di polizia, ed utilizzato specificatamente come strumento coattivo e antisommossa.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('04-02-2004', 'Militanti armati in un attacco combinato hanno aggredito, minacciato e rotto gli arti di Owen Gatty, uno stretto aiuto politico del presidente dell''Assemblea legislativa statale, e del Ministro degli Interni cinese Guo Sung con il quale si era registrato un giro di affari.', 'Assassinio', 'Governo', 'La tortura di Canberra', '13');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('13', 'AK-47', '10');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('13', 'Manganello', '10');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('14', 'AK-47', '10');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('14', 'Manganello', '10');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('-35.282000, 149.128684','10');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('39.904200, 116.407396','10');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Owen','Gatty','22-06-1996','Australia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Guo','Sung','13-05-1978','Cina');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('33','10','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('34','10','Ferito');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Chiabuotu', 'Kwemto', '06-02-1975', 'Etiopia', 'Maschio', '184');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  	VALUES('9.005401, 38.763611','Africa','Etiopia','Addis Abaha');
INSERT INTO Arma(nome, tipo,descrizione)
  VALUES('Renault Kerax','Veicolo','Il Renault Kerax è un autocarro che è stato prodotto dal costruttore francese Renault
		 Véhicules Industriels e successivamente dalla Renault Trucks (parte di Renault, poi parte del gruppo Volvo) dal 1997 al 2013.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('08-03-1994', 'Fanatico si è impossessato di un autocarro prelevato da un cantiere e si è diretto sulla folla, provocando il terrore tra i pedoni.', 'Veicolo su folla', 'Cittadini', 'Kerax Strike', '15');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('15', 'Renault Kerax', '11');
INSERT INTO Collocazione(luogo, attentato)
  VALUES('9.005401, 38.763611','11');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Kwemtochukwu','Azubuike','18-01-1957','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Ginikanwa','Nebechi','24-01-1980','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Zikoranaudodimma','Anayochukwu','05-10-1657','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Ofodile','Udobata','18-04-1948','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Chioke','Ajuluchukwu','24-11-1958','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Onyeoruru','Onwudiwe','10-11-1968','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Evertje','Blank','16-09-1953','Olanda');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Jorginho','de Kanter','07-03-1966','Olanda');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Léon','Cressac','25-04-1961','Francia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Arjen','Malen','07-11-1944','Olanda');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Buchi','Esomchi','19-10-1985','Nigeria');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Grégoire','Vincent','01-12-1969','Francia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Okeke','Rapuluolisa','12-06-1939','Senegal');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Chinyelu','Nkemdirim','07-02-1975','Nigeria');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Diribe','Abazu','06-02-1968','Marocco');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Adamma','Chukwuraenye','21-03-1970','Etiopia');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Abdul-Hayy','Barir Quraishi','11-02-1976','Arabia Saudita');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  VALUES('Jad Allah','Sabeeh Wasem','20-07-1943','Arabia Saudita');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('18','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('25','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('35','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('36','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('37','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('38','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('39','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('40','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('41','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('42','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('43','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('44','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('45','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('46','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('47','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('48','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('49','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('50','11','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('51','11','Ferito');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  VALUES('52','11','Ferito');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Racław', 'Król', '07-12-1993', 'Polonia', 'Maschio', '179');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  	VALUES('67.280356, 14.404916','Europa','Norvegia','Bodo');
INSERT INTO Arma(nome, tipo,descrizione)
  	VALUES('Mazza da baseball','Arma bianca','La mazza da baseball è un bastone di legno massiccio o di metallo cavo utilizzato
		 nel gioco del baseball per colpire la palla. Il giocatore che la impugna, con ambo le mani, è chiamato battitore.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('05-07-2008', 'Miitante ha ucciso un membro dell''ala giovanile del Fronte popolare di Bodo (BPF).', 'Assalto armato', 'Partito politico', 'Bodo''s Heist', '16');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  	VALUES('Fernanda','Rodriguez','10-07-1986','Spagna');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('16', 'Mazza da baseball', '12');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('67.280356, 14.404916','12');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  	VALUES('53','12','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Wajid', 'Hakim Kassis', '15-02-1971', 'Arabia Saudita', 'Maschio', '181');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  	VALUES('11.707235, 11.082491','Africa','Nigeria','Potiskum');
INSERT INTO Arma(nome, tipo,descrizione)
  	VALUES('Advanced Combat Knife','Arma bianca','Il coltello fu sviluppato dalla società di Solingen Eickhorn
		 e presentava una lama tipo Bowie come una sega sul retrolama e con funzionalità di coltello da combattimento pesante');
INSERT INTO Arma(nome, tipo,descrizione)
  	VALUES('Molotov','Ordigno esplosivo','La bomba Molotov (comunemente Molotov o bottiglia Molotov) è un ordigno di tipo incendiario,
		   spesso utilizzato in azioni di guerriglia o in violente proteste di piazza.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('24-10-2012', 'Gli assalitori hanno dato fuoco al College of Administration nella città di Potiskum, nello stato di Yobe,
		   in Nigeria.', 'Istituzione', 'College of Admnistration', 'Operazione ''Scintilla''', '15');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('17', 'Advanced Combat Knife', '13');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('15', 'Advanced Combat Knife', '13');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('17', 'Molotov', '13');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('15', 'Molotov', '13');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('11.707235, 11.082491','13');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Lan', 'Lan Hsüeh', '26-08-1995', 'Afghanistan', 'Femmina', '165');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  	VALUES('34.533333, 69.166667','Asia','Afghanistan','Kabul');
INSERT INTO Arma(nome, tipo,descrizione)
  	VALUES('Acido fluoroacetico','Veleno','L''acido fluoroacetico è il derivato dall''acido acetico sostituendo un idrogeno del
		   gruppo metilico con un atomo di fluoro. In condizioni normali è un solido cristallino incolore e inodore,
		   facilmente solubile in acqua. È un acido carbossilico altamente tossico.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('20-01-2011', 'L''assalitore ha avvelenato il cibo del pranzo in un centro di addestramento dell''esercito nazionale afgano
		   (ANA) nella prigione di Pol-e Charkhi, provincia della città di Kabul, Afghanistan.', 'Avvelenamento', 'Base Militare', 'Poison Army', '18');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  	VALUES('Kang','Hsia','26-09-1955','Afghanistan');
INSERT INTO Vittima(nome, cognome,dataDiNascita,nazionalita)
  	VALUES('Xia','Pan','21-11-1990','Afghanistan');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('18', 'Acido fluoroacetico', '14');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('34.533333, 69.166667','14');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  	VALUES('22','14','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  	VALUES('54','14','Morto');
INSERT INTO Coinvolgimento(vittima,attentato,condizione)
  	VALUES('55','14','Morto');

COMMIT WORK;

INSERT INTO Terrorista(nome, cognome, dataDiNascita, nazionalita, sesso, altezza)
	VALUES('Beat', 'Regalado Valles', '15-10-2000', 'Argentina', 'Maschio', '169');
INSERT INTO Luogo(coordinate, continente,nazione,citta)
  	VALUES('27.717245, 85.323960','Asia','Nepal','Katmandu');
INSERT INTO Arma(nome, tipo,descrizione)
  	VALUES('High Explosive Anti-Tank','Ordigno esplosivo','High Explosive Anti-Tank, meglio noto con l''acronimo HEAT,
		   ossia esplosivo ad alto potenziale contro-carri, indica un particolare tipo di munizionamento anticarro a carica cava.');
INSERT INTO Attentato(dataAvvenimento, descrizione, tipologia, obiettivo, nomeOperazione, capo)
	VALUES('04-02-2004', 'Un ordigno esplosivo è esploso contro il veicolo di Jhala Nath Khanal.', 'Assassinio', 'Personaggio politico', 'Attacco a Khanal', '19');
INSERT INTO Offensiva(terrorista, arma, attentato)
	VALUES('19', 'High Explosive Anti-Tank', '15');
INSERT INTO Collocazione(luogo, attentato)
  	VALUES('27.717245, 85.323960','15');

/*Popolamento della tabella 'Organizzazione'*/
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Continuity US Republican Army', '06-08-1986', '2000', 'Politico', NULL, 'Estremismo statunitense', 'Gerry', 'Adams');
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Euskadi Ta Askatasuna', '12-11-1958', '500', 'Politico', NULL, 'Nazionalismo afghano', 'David', 'Pla');
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Brigate Ezzedin al-Qassam', '07-01-1992', '1000', 'Religioso', 'Antisionismo', NULL, 'Yahya', 'Ayyash');
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Loyalist Volunteer Force', '27-07-1996', '3700', 'Religioso', 'Antipapismo', NULL, 'Billy', 'Wright');
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Jihad Islamico Palestinese', '26-12-1987', '980', 'Politico', NULL, 'Jihādismo', 'Fathi', 'Shaqaqi');
INSERT INTO Organizzazione(nomeGruppo, fondazione, numeroComponenti, tipo, dottrina, orientamento, nomeLeader, cognomeLeader)
	VALUES('Brigate dei Martiri di al-Aqsa', '03-11-2000', '2700', 'Religioso', 'Antisionismo', NULL, 'Yasser', 'Arafat');

/*Popolamento della tabella 'Influenza'*/
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('10-10-1990','1','04-11-1998','Gli Stati Uniti sono un grande Paese e meritano di governare il mondo.','false','Continuity US Republican Army');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('1-02-1999','1',NULL,'La guerra è pace, ci permette di liberarci dagli oppressori','true','Euskadi Ta Askatasuna');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('12-03-2000','2',NULL,'Gli americani ci hanno rubato tutto, meritano di essere puniti','true','Jihad Islamico Palestinese');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('05-09-1995','3','01-01-2001','Offrite i vostri cuori all''unico Dio benevolo, e ripudiate il demonio nelle forme del Dio ebraico','false','Brigate dei Martiri di al-Aqsa');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('24-06-2005','4',NULL,'Il papa è il servo del diavolo, non di Dio, merita di subire le stesse punizione che ha inflitto ai nostri fratelli','true','Loyalist Volunteer Force');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('16-07-2003','5','01-10-2004','Hamas è la nostra via maestra, servitela e sarete liberiq','false','Brigate Ezzedin al-Qassam');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('11-09-2008','8',NULL,'David ha dato il sangue per il nostro popolo, è l''ora di ringraziarlo','true','Euskadi Ta Askatasuna');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('22-05-1999','9',NULL,'L''Irlanda è nostra e qui comandiamo noi','true','Continuity US Republican Army');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('24-01-2009','10','24-08-2011','Un vero pastore di anime non condannerebbe mai alla gogna delle sue povere pecore','false','Loyalist Volunteer Force');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
	VALUES('25-08-2011','10',NULL,'L''Islam vi donerà la vita eterna, per ottenerla dovrete sacrificare voi stessi per la causa contro il diavolo','true','Jihad Islamico Palestinese');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('08-10-2010','11','28-12-2015','Fatah deve governare il nostro paese','false','Brigate dei Martiri di al-Aqsa');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('29-12-2015','11','25-06-2019','Gli accordi di Oslo hanno rovinato tutto dobbiamo liberare il nostro paese','false','Brigate Ezzedin al-Qassam');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('26-06-2019','11',NULL,'Il jihād è un obbligo da attuare contro Israele','true','Jihad Islamico Palestinese');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('19-08-2010','13',NULL,'Abbasso il sionismo','true','Brigate dei Martiri di al-Aqsa');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('09-04-2011','14',NULL,'Il comandante Mohammed Deif ci mostrerà la via','true','Brigate Ezzedin al-Qassam');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('17-07-2014','15','15-01-2018','Il cristianesimo è il male dell''umanità','false','Loyalist Volunteer Force');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('16-01-2018','15','12-03-2021','Allah è grande ed il nostro profeta','false','Brigate dei Martiri di al-Aqsa');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('21-03-2013','17',NULL,'I musulmani si stanno occidentalizzando troppo bisogna tornare ai valori tradizionali','true','Jihad Islamico Palestinese');
INSERT INTO Influenza(dataInizio, terrorista,dataFine,descrizione,attuale,organizzazione)
  VALUES('27-02-2010','18',NULL,'La repubblica è stata la rovina dell''Irlanda','true','Loyalist Volunteer Force');

COMMIT WORK;

/*Popolamento della tabella 'Soprannome'*/
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Undertaker','1');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Munzieddo','1');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Boeing747','3');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('El General','2');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Pelle di maiale','4');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('El Alamo','6');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Monco','7');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Engeniero','8');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Nisba','10');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Viper','10');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Alamo','11');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Afeaa','12');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Almudamir','13');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Kamaasha','14');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Almualim','15');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Mismar','15');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Blyat','15');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Qisab','16');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Almurawid','17');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Die Reus','17');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Vet','17');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Tyrana','17');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Die Onderwereld','17');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Esper','18');
INSERT INTO Soprannome(appellativo, terrorista)
  VALUES('Diablo','19');

/*Popolamento della tabella 'Associazione'*/
INSERT INTO Associazione(attentatoPadre, attentatoDerivato, Descrizione)
	VALUES('11', '13', 'Motivo del legame tra i due attentati: lo stesso terrorista a capo dell''attacco.');
INSERT INTO Associazione(attentatoPadre, attentatoDerivato, Descrizione)
	VALUES('4', '3', 'Motivo del legame tra i due attentati: lo stesso terrorista a capo dell''attacco.');
