/*Query che stampa i capi di ogni attentato, di nazionalità araba, con i rispettivi numeri di influenze*/
SELECT T.identificativo AS Capo, T.nome, T.cognome, COUNT(I.terrorista) AS NumeroInfluenze
	FROM Terrorista T, Attentato A, Influenza I WHERE T.identificativo=A.capo and I.terrorista=T.identificativo
		GROUP BY T.identificativo HAVING T.nazionalita='Arabia Saudita';

/*Query che stampa i capi di ogni attentato, di nazionalità araba, con i rispettivi numeri di influenze con JOIN ESPLICITO*/
SELECT T.Identificativo AS Capo, T.nome, T.cognome, COUNT(I.Terrorista) AS NumeroInfluenze
	FROM Terrorista T JOIN Attentato A ON T.Identificativo=A.Capo
	JOIN Influenza I ON I.Terrorista=T.Identificativo GROUP BY T.Identificativo HAVING T.Nazionalita='Arabia Saudita';

/*Query che stampa tutti i terroristi che hanno partecipato a più di un attentato*/
SELECT * FROM TERRORISTA T
	WHERE 1<(SELECT COUNT(*) FROM (SELECT COUNT (*) FROM OFFENSIVA
										WHERE Terrorista = T.Identificativo GROUP BY Attentato) AS attentati_diversi);

/*Trovare e mostrare l’ID, il nome,il cognome e la nazionalità di tutti i terroristi che non sono mai stati capi in un attentato.*/
SELECT T.Identificativo, T.nome, T.cognome,T.nazionalita FROM TERRORISTA T, ATTENTATO A
EXCEPT
SELECT T.Identificativo, T.nome, T.cognome,T.nazionalita FROM TERRORISTA T, ATTENTATO A
    WHERE T.Identificativo = A.Capo ORDER BY Identificativo;

/*Query che sotto un'influenza di almeno 10 anni durante un attentato*/
SELECT * FROM Terrorista T
	WHERE T.identificativo IN(SELECT I.Terrorista FROM Influenza I
								WHERE I.Terrorista=T.identificativo AND T.identificativo IN(SELECT I2.terrorista FROM Influenza I2
																								WHERE I2.datafine IS null AND EXTRACT(YEAR FROM datainizio)>EXTRACT ( YEAR FROM current_date - interval '10 year'))
							 );

/*Query nidificata che trova le vittime presenti in più attentati*/
SELECT * FROM Vittima V
	WHERE 1<(SELECT COUNT(*) FROM Coinvolgimento
				WHERE vittima=V.codice);

/*Viste*/
CREATE VIEW attentatiInEuropa AS
	(SELECT attentato, nomeOperazione, nazione, citta, luogo as coordinate FROM Collocazione C, Luogo L, Attentato A
	 	WHERE L.continente='Europa' AND C.luogo=L.coordinate AND A.codice=C.attentato);

CREATE VIEW attentatiInAsia AS
	(SELECT attentato, nomeOperazione, nazione, citta, luogo as coordinate FROM Collocazione C, Luogo L, Attentato A
	 	WHERE L.continente='Asia' AND C.luogo=L.coordinate AND A.codice=C.attentato);

CREATE VIEW attentatiInAmerica AS
	(SELECT attentato, nomeOperazione, nazione, citta, luogo as coordinate FROM Collocazione C, Luogo L, Attentato A
	 	WHERE L.continente='America' AND C.luogo=L.coordinate AND A.codice=C.attentato);

CREATE VIEW attentatiInOceania AS
	(SELECT attentato, nomeOperazione, nazione, citta, luogo as coordinate FROM Collocazione C, Luogo L, Attentato A
	 	WHERE L.continente='Oceania' AND C.luogo=L.coordinate AND A.codice=C.attentato);

CREATE VIEW attentatiInAfrica AS
	(SELECT attentato, nomeOperazione, nazione, citta, luogo as coordinate FROM Collocazione C, Luogo L, Attentato A
	 	WHERE L.continente='Africa' AND C.luogo=L.coordinate AND A.codice=C.attentato);

CREATE VIEW attentatiConArmiDaFuoco AS
	(SELECT DISTINCT  attentato, nome as nome_arma, descrizione FROM Offensiva O, Arma AR
		WHERE  O.arma=AR.nome and AR.tipo='Arma da Fuoco'
		ORDER BY O.attentato);

CREATE VIEW attentatiSenzaArmiDaFuoco AS
	(SELECT DISTINCT  attentato, nome as nome_arma, descrizione FROM Offensiva O, Arma AR
		WHERE  O.arma=AR.nome and AR.tipo<>'Arma da Fuoco'
		ORDER BY O.attentato);


/*Utilizzo della vista 'attentatiInEuropa' per il calcolo delle vittime in Europa*/
SELECT SUM(numeroVittime) AS NumeroDiVitime FROM Attentato A, attentatiInEuropa AE
	WHERE A.codice=AE.attentato;

/*Utilizzo della vista 'attentatiInAsia' per il calcolo delle vittime in Asia*/
SELECT SUM(numeroVittime) AS NumeroDiVitime FROM Attentato A, attentatiInAsia AAs
	WHERE A.codice=AAs.attentato;

/*Utilizzo della vista 'attentatiInAmerica' per il calcolo delle vittime in America*/
SELECT SUM(numeroVittime) AS NumeroDiVitime FROM Attentato A, attentatiInAmerica AAm
	WHERE A.codice=AAm.attentato;

/*Utilizzo della vista 'attentatiInOceania' per il calcolo delle vittime in Oceania*/
SELECT SUM(numeroVittime) AS NumeroDiVitime FROM Attentato A, attentatiInOceania AO
	WHERE A.codice=AO.attentato;

/*Utilizzo della vista 'attentatiInAfrica' per il calcolo delle vittime in Africa*/
SELECT SUM(numeroVittime) AS NumeroDiVitime FROM Attentato A, attentatiInAfrica AAf
	WHERE A.codice=AAf.attentato;

/*Utilizzo della vista 'attentatiConArmiDaFuoco' per il calcolo delle vittime causate da ogni attacco dove sono state usate armi da fuoco*/
SELECT A.nomeOperazione, A.numeroVittime, AAF.nome_arma, AAF.descrizione FROM attentatiConArmiDaFuoco AAF, Attentato A
	WHERE AAF.attentato=A.codice;	
