/*Trigger di popolamento*/
CREATE OR REPLACE FUNCTION controlloOffensiva_Attentato() /*Trigger di Inserimento dell'Attentato*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Offensiva
			WHERE Offensiva.attentato=NEW.codice;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Offensiva'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER addOffensiva_Attentato
AFTER INSERT
ON Attentato
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloOffensiva_Attentato();


CREATE OR REPLACE FUNCTION controlloOffensiva_Terrorista() /*Trigger di Inserimento del Terrorista*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Offensiva
			WHERE Offensiva.terrorista=NEW.identificativo;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Offensiva'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER addOffensiva_Terrorista
AFTER INSERT
ON Terrorista
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloOffensiva_Terrorista();

CREATE OR REPLACE FUNCTION controlloOffensiva_Arma() /*Trigger di Inserimento dell'Arma*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Offensiva
			WHERE Offensiva.arma=NEW.nome;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Offensiva'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER addOffensiva_Arma
AFTER INSERT
ON Arma
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloOffensiva_Arma();

CREATE OR REPLACE FUNCTION controlloOrganizzazione() /*Trigger di Inserimento dell'Organizzazione*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Influenza
			WHERE Influenza.organizzazione=NEW.nomeGruppo;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché non sono presenti occorrenze in Influenza'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER Organizzazione_controllo
AFTER INSERT OR UPDATE
ON Organizzazione
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloOrganizzazione();

CREATE OR REPLACE FUNCTION controlloCoinvolgimento_Vittima() /*Trigger di Inserimento della Vittima*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Coinvolgimento
			WHERE Coinvolgimento.vittima=NEW.codice;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Coinvolgimento'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER addCoinvolgimento_Vittima
AFTER INSERT
ON Vittima
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloCoinvolgimento_Vittima();

CREATE OR REPLACE FUNCTION controlloCollocazione_Attentato() /*Trigger di Inserimento dell'Attentato tramite la Collocazione*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Collocazione
			WHERE Collocazione.attentato=NEW.codice;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Collocazione'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

/*Il trigger addCollocazione_Attentato si preoccupa, nel momento di inserimento di un attentato, di controllare se sono presenti
occorrenze in Collocazione, in caso contrario blocca l’operazione. Per effettuare ciò conta le occorrenze presenti in Collocazione
quando il codice dell’attentato coincide con quello appena inserito, se il risultato fa 0 allora l’operazione di inserimento viene
bloccata.*/
CREATE CONSTRAINT TRIGGER addCollocazione_Attentato
AFTER INSERT
ON Attentato
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloCollocazione_Attentato();

CREATE OR REPLACE FUNCTION controlloCollocazione_Luogo() /*Trigger di Inserimento del Luogo tramite la Collocazione*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN
		SELECT count(*) INTO conto from Collocazione
			WHERE Collocazione.luogo=NEW.coordinate;
		IF ( conto = 0 )
		THEN
	 		RAISE EXCEPTION $$'Non è stato possibile aggiungere % perché non sono presenti occorrenze in Collocazione'$$, NEW;
  		ELSE
  			return NEW;
  END IF;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER addCollocazione_Luogo
AFTER INSERT
ON Luogo
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE controlloCollocazione_Luogo();

/*Il trigger updateOffensiva si preoccupa, nel momento di update di un’offensiva, di controllare se sono presenti occorrenze in
Offensiva con i vecchi valori della tupla aggiornata. In caso non fosse presente qualcuno di questi, si procede ad eliminare
l’occorrenza nella sua relativa tabella.*/
CREATE OR REPLACE FUNCTION Offensiva_update() /*Trigger di Update dell'Offensiva*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	armamento integer;
	criminale integer;
	attacco integer;
	BEGIN
		SELECT count(*) INTO armamento from Offensiva
			WHERE Offensiva.arma=OLD.arma;

		IF ( armamento = 0 )
		THEN
			DELETE FROM Arma
				WHERE Arma.nome=OLD.arma;
		END IF;

		SELECT count(*) INTO criminale from Offensiva
			WHERE Offensiva.terrorista=OLD.terrorista;

		IF ( criminale = 0 )
		THEN
			UPDATE Attentato
				SET capo=NEW.terrorista
				WHERE capo=OLD.terrorista;
			DELETE FROM Terrorista
				WHERE identificativo=OLD.terrorista;
		END IF;

		SELECT count(*) INTO attacco from Offensiva
			WHERE Offensiva.attentato=OLD.attentato;

		IF ( attacco = 0 )
		THEN
			DELETE FROM Attentato
				WHERE codice=OLD.attentato;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER updateOffensiva
AFTER UPDATE
ON Offensiva
FOR EACH ROW
EXECUTE PROCEDURE Offensiva_update();

CREATE OR REPLACE FUNCTION Coinvolgimento_update() /*Trigger di Update del Coinvolgimento*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	civile integer;
	attacco integer;
	BEGIN
		SELECT count(*) INTO civile from Coinvolgimento
			WHERE Coinvolgimento.vittima=OLD.vittima;

		IF ( civile = 0 )
		THEN
			DELETE FROM Vittima
				WHERE codice=OLD.vittima;
		END IF;

		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER updateCoinvolgimento
AFTER UPDATE
ON Coinvolgimento
FOR EACH ROW
EXECUTE PROCEDURE Coinvolgimento_update();

CREATE OR REPLACE FUNCTION Collocazione_update() /*Trigger di Update della Collocazione*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	posizione integer;
	attacco integer;
	BEGIN
		SELECT count(*) INTO attacco from Collocazione
			WHERE attentato=OLD.attentato;

		IF ( attacco = 0 )
		THEN
			RAISE EXCEPTION $$'Non è stato possibile eliminare % perché il relativo attentato è presente in Offensiva'$$, OLD;
		END IF;

		SELECT count(*) INTO posizione from Collocazione
			WHERE luogo=OLD.luogo;

		IF ( posizione = 0 )
		THEN
			DELETE FROM Luogo
				WHERE coordinate=OLD.luogo;
		END IF;

		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER updateCollocazione
AFTER UPDATE
ON Collocazione
FOR EACH ROW
EXECUTE PROCEDURE Collocazione_update();

CREATE OR REPLACE FUNCTION Offensiva_delete() /*Trigger di Cancellazione dell'Offensiva*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	attacco integer;
	criminale integer;
	armamento integer;
	BEGIN

		SELECT count(*) INTO attacco from Offensiva
			WHERE Offensiva.attentato=OLD.attentato;

		IF ( attacco = 0 )
		THEN
			DELETE FROM Attentato
				WHERE codice=OLD.attentato;
		END IF;

		SELECT count(*) INTO criminale from Offensiva
			WHERE Offensiva.terrorista=OLD.terrorista;

		IF ( criminale = 0 )
		THEN
			DELETE FROM Terrorista
				WHERE identificativo=OLD.terrorista;
		END IF;

		SELECT count(*) INTO armamento from Offensiva
			WHERE Offensiva.arma=OLD.arma;

		IF ( armamento = 0 )
		THEN
			DELETE FROM Arma
				WHERE nome=OLD.arma;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER deleteOffensiva
AFTER DELETE
ON Offensiva
FOR EACH ROW
EXECUTE PROCEDURE Offensiva_delete();

CREATE OR REPLACE FUNCTION Coinvolgimento_delete() /*Trigger di Cancellazione del Coinvolgimento*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	civile integer;
	BEGIN

		SELECT count(*) INTO civile from Coinvolgimento
			WHERE Coinvolgimento.vittima=OLD.vittima;

		IF ( civile = 0 )
		THEN
			DELETE FROM Vittima
				WHERE codice=OLD.vittima;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER deleteCoinvolgimento
AFTER DELETE
ON Coinvolgimento
FOR EACH ROW
EXECUTE PROCEDURE Coinvolgimento_delete();

CREATE OR REPLACE FUNCTION Collocazione_delete() /*Trigger di Cancellazione della Collocazione*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	posizione integer;
	conto integer;
	BEGIN

		SELECT count(*) INTO posizione from Collocazione
			WHERE Collocazione.luogo=OLD.luogo;

		IF ( posizione = 0 )
		THEN
			DELETE FROM Luogo
				WHERE coordinate=OLD.luogo;

			SELECT count(*) INTO conto from Offensiva
			WHERE Offensiva.attentato=OLD.attentato;

			IF ( conto = 0 )
			THEN
				DELETE FROM Attentato
					WHERE codice=OLD.attentato;
			ELSE
				RAISE EXCEPTION $$'Non è stato possibile eliminare % perché il relativo attentato è presente in Offensiva'$$, OLD;
			END IF;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER deleteCollocazione
AFTER DELETE
ON Collocazione
FOR EACH ROW
EXECUTE PROCEDURE Collocazione_delete();

/*Trigger aziendali*/
CREATE OR REPLACE FUNCTION Capo_controllo() /*Trigger di controllo del Capo che partecipi all'attacco*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN

		SELECT count(*) INTO conto from Offensiva
			WHERE Offensiva.attentato=NEW.codice and Offensiva.terrorista=NEW.capo;

		IF ( conto = 0 )
		THEN
			RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché il capo non partecipa all''attacco'$$, NEW;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloCapo
AFTER INSERT OR UPDATE
ON Attentato
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE Capo_controllo();

CREATE OR REPLACE FUNCTION Deceduto_controllo() /*Trigger di Controllo che un defunto non sia presente in attentati futuri*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	momento date;
	morto varchar(8);
	BEGIN

		SELECT Attentato.dataAvvenimento INTO momento FROM Attentato
			WHERE Attentato.codice=NEW.attentato;

		SELECT Coinvolgimento.condizione INTO morto FROM Attentato,Coinvolgimento
			WHERE Attentato.dataAvvenimento<momento and Attentato.codice=Coinvolgimento.attentato and Coinvolgimento.condizione='Morto' and Coinvolgimento.vittima=NEW.vittima;

		IF ( morto is  NOT NULL )
		THEN
			RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché è già morto'$$, NEW;
		END IF;
		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloDeceduto
AFTER INSERT OR UPDATE
ON Coinvolgimento
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE Deceduto_controllo();

CREATE OR REPLACE FUNCTION Vittime_controllo() /*Trigger Aggiornamento del numero delle vittime*/
RETURNS TRIGGER AS $BODY$
	DECLARE
	conto integer;
	BEGIN

		SELECT count(*) INTO conto FROM Coinvolgimento
			WHERE attentato=NEW.attentato;

		UPDATE Attentato
			SET numeroVittime=conto
			WHERE codice=NEW.attentato;

		SELECT count(*) INTO conto FROM Coinvolgimento
			WHERE attentato=OLD.attentato;

		UPDATE Attentato
			SET numeroVittime=conto
			WHERE codice=OLD.attentato;

		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloVittime
AFTER INSERT OR UPDATE
ON Coinvolgimento
FOR EACH ROW
EXECUTE PROCEDURE Vittime_controllo();

CREATE OR REPLACE FUNCTION Associazione_controllo() /*Trigger di Controllo che un attentato non derivi da sé stesso*/
RETURNS TRIGGER AS $BODY$
	BEGIN

		IF( NEW.attentatoPadre = NEW.attentatoDerivato )
		THEN
			RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché un attentato non può derivare da se stesso'$$, NEW;
		END IF;

		return NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloAssociazione
AFTER INSERT OR UPDATE
ON Associazione
FOR EACH ROW
EXECUTE PROCEDURE Associazione_controllo();

CREATE OR REPLACE FUNCTION NascitaVittima_controllo() /*Trigger di Controllo che una vittima non sia nata dopo l'attentato in cui è coinvolta*/
RETURNS TRIGGER AS $BODY$
  DECLARE
  nascita date;
  episodio date;

  BEGIN

    SELECT dataDiNascita INTO nascita FROM Vittima
      WHERE codice=NEW.vittima;

    IF ( nascita IS NOT NULL )
    THEN
      SELECT dataAvvenimento INTO episodio FROM Attentato
      WHERE codice=NEW.attentato;

      IF( nascita> episodio)
      THEN
        RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché la vittima non è ancora nata'$$, NEW;
      END IF;
    END IF;

    return NEW;
  END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloNascitaVittima
AFTER INSERT OR UPDATE
ON Coinvolgimento
FOR EACH ROW
EXECUTE PROCEDURE NascitaVittima_controllo();


CREATE OR REPLACE FUNCTION NascitaTerrorista_controllo() /*Trigger di Controllo che una terrorista non sia nato dopo l'attentato a cui partecipa*/
RETURNS TRIGGER AS $BODY$
  DECLARE
  nascita date;
  episodio date;
  BEGIN

    SELECT dataDiNascita INTO nascita FROM Terrorista
      WHERE identificativo=NEW.terrorista;

    SELECT dataAvvenimento INTO episodio FROM Attentato
      WHERE codice=NEW.attentato;

    IF( nascita > episodio )
      THEN
      	RAISE EXCEPTION $$'Non è stato possibile aggiungere o aggiornare % perché il terrorista non è ancora nato.'$$, NEW;
    END IF;
    return NEW;
  END;
$BODY$
LANGUAGE PLPGSQL;

CREATE CONSTRAINT TRIGGER controlloNascitaTerrorista
AFTER INSERT OR UPDATE
ON Offensiva
FOR EACH ROW
EXECUTE PROCEDURE NascitaTerrorista_controllo();
