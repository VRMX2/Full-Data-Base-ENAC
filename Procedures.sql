-- Table Region

-- Procedure create Region
CREATE PROCEDURE CreateRegion
    @Nom NVARCHAR(100)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Region WHERE Nom = @Nom)
    BEGIN
        RAISERROR('Region name already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Region (Nom)
    VALUES (@Nom);

    SELECT SCOPE_IDENTITY() AS IdRegion;
END;
GO

-- Procedure Update Region
CREATE PROCEDURE UpdateRegion
    @IdRegion INT,
    @Nom NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Region WHERE IdRegion = @IdRegion)
    BEGIN
        RAISERROR('Region does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Region
    SET Nom = @Nom
    WHERE IdRegion = @IdRegion;

    SELECT 'Region updated successfully.' AS Message;
END;
GO

-- Procedure Delete Region
CREATE PROCEDURE DeleteRegion
    @IdRegion INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Region WHERE IdRegion = @IdRegion)
    BEGIN
        RAISERROR('Region does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Region
    WHERE IdRegion = @IdRegion;

    SELECT 'Region deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetRegionById
    @IdRegion INT
AS
BEGIN
    SELECT IdRegion, Nom
    FROM Region
    WHERE IdRegion = @IdRegion;
END;
GO

CREATE PROCEDURE ListAllRegions
AS
BEGIN
    SELECT IdRegion, Nom
    FROM Region;
END;
GO

CREATE PROCEDURE sp_InsertStock
    @IdMedicament INT,
    @Quantite INT,
    @Famille VARCHAR(50) = NULL,
    @Reference VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Stock (IdMedicament, Quantite, Famille, Reference)
	VALUES (@IdMedicament, @Quantite, @Famille, @Reference);
    
    SELECT SCOPE_IDENTITY() AS IdStock;
END

Go
CREATE PROCEDURE sp_GetStockById
    @IdStock INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT IdStock, IdMedicament, Quantite, Famille, Reference
    FROM Stock
    WHERE IdStock = @IdStock;
END
Go
CREATE PROCEDURE sp_GetAllStocks
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT IdStock, IdMedicament, Quantite, Famille, Reference
    FROM Stock;
END
Go
CREATE PROCEDURE sp_UpdateStock
    @IdStock INT,
    @IdMedicament INT,
    @Quantite INT,
    @Famille VARCHAR(50) = NULL,
    @Reference VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Stock
    SET IdMedicament = @IdMedicament,
        Quantite = @Quantite,
        Famille = @Famille,
        Reference = @Reference
    WHERE IdStock = @IdStock;
    
    RETURN @@ROWCOUNT;
END
Go
CREATE PROCEDURE sp_DeleteStock
    @IdStock INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Stock
    WHERE IdStock = @IdStock;
    
    RETURN @@ROWCOUNT;
END
Go

CREATE PROCEDURE sp_CheckStockQuantity
    @IdMedicament INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Quantite
    FROM Stock
    WHERE IdMedicament = @IdMedicament;
END
Go
CREATE PROCEDURE sp_UpdateStockQuantity
    @IdStock INT,
    @QuantityChange INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Stock
    SET Quantite = Quantite + @QuantityChange
    WHERE IdStock = @IdStock
    AND (Quantite + @QuantityChange) >= 0;
    
    IF @@ROWCOUNT = 0
        RAISERROR('Insufficient stock or invalid stock ID', 16, 1);
END
Go


CREATE PROCEDURE sp_GetStockByMedicamentId
    @IdMedicament INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT IdStock, Quantite, Famille, Reference
    FROM Stock
    WHERE IdMedicament = @IdMedicament;
END
Go

CREATE PROCEDURE sp_SearchStockByFamily
    @Famille VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT s.IdStock, s.IdMedicament, s.Quantite, s.Reference, m.NomMedicament AS MedicamentName
    FROM Stock s
    JOIN Medicament m ON s.IdMedicament = m.IdMedicament
    WHERE s.Famille LIKE '%' + @Famille + '%';
END
Go
CREATE PROCEDURE sp_GetLowStockItems
    @Threshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT s.IdStock, s.IdMedicament, s.Quantite, s.Famille, s.Reference, m.NomMedicament AS MedicamentName
    FROM Stock s
    JOIN Medicament m ON s.IdMedicament = m.IdMedicament
    WHERE s.Quantite <= @Threshold
    ORDER BY s.Quantite ASC;
END
Go

CREATE PROCEDURE CreateUser
    @ActiveDirectoryID NVARCHAR(255),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255),
    @Role NVARCHAR(50),
    @IdRegion INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Utilisateur WHERE Username = @Username)
    BEGIN
        RAISERROR('Username already exists.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Utilisateur WHERE ActiveDirectoryID = @ActiveDirectoryID)
    BEGIN
        RAISERROR('Active Directory ID already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Utilisateur (ActiveDirectoryID, Username, Password, Role, IdRegion)
    VALUES (@ActiveDirectoryID, @Username, @Password, @Role, @IdRegion);

    SELECT SCOPE_IDENTITY() AS IdUtilisateur;
END;
GO

CREATE PROCEDURE DeleteUser
    @IdUtilisateur INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Utilisateur WHERE IdUtilisateur = @IdUtilisateur)
    BEGIN
        RAISERROR('User does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Utilisateur
    WHERE IdUtilisateur = @IdUtilisateur;

    SELECT 'User deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE AuthenticateUser
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Utilisateur WHERE Username = @Username AND Password = @Password)
    BEGIN
        SELECT IdUtilisateur, ActiveDirectoryID, Username, Role, IdRegion, DateCreation
        FROM Utilisateur
        WHERE Username = @Username AND Password = @Password;
    END
    ELSE
    BEGIN
        RAISERROR('Invalid username or password.', 16, 1);
    END
END;
GO

CREATE PROCEDURE GetUserById
    @IdUtilisateur INT
AS
BEGIN
    SELECT IdUtilisateur, ActiveDirectoryID, Username, Role, IdRegion, DateCreation
    FROM Utilisateur
    WHERE IdUtilisateur = @IdUtilisateur;
END;
GO

CREATE PROCEDURE ListAllUsers
AS
BEGIN
    SELECT IdUtilisateur, ActiveDirectoryID, Username, Role, IdRegion, DateCreation
    FROM Utilisateur;
END;
GO

CREATE PROCEDURE CreatePatient
    @IdRegion INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @DateNaissance DATE,
    @Sexe CHAR(1),
    @Structure NVARCHAR(100),
    @Adresse NVARCHAR(255),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255),
    @Poids INT,
    @Taille INT,
    @GroupeSanguin NVARCHAR(5)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Patient WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Patient (IdRegion, Nom, Prenom, DateNaissance, Sexe, Structure, Adresse, Telephone, Email, Poids, Taille, GroupeSanguin)
    VALUES (@IdRegion, @Nom, @Prenom, @DateNaissance, @Sexe, @Structure, @Adresse, @Telephone, @Email, @Poids, @Taille, @GroupeSanguin);

    SELECT SCOPE_IDENTITY() AS IdPatient;
END;
GO

CREATE PROCEDURE UpdatePatient
    @IdPatient INT,
    @IdRegion INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @DateNaissance DATE,
    @Sexe CHAR(1),
    @Structure NVARCHAR(100),
    @Adresse NVARCHAR(255),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255),
    @Poids INT,
    @Taille INT,
    @GroupeSanguin NVARCHAR(5)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Patient
    SET
        IdRegion = @IdRegion,
        Nom = @Nom,
        Prenom = @Prenom,
        DateNaissance = @DateNaissance,
        Sexe = @Sexe,
        Structure = @Structure,
        Adresse = @Adresse,
        Telephone = @Telephone,
        Email = @Email,
        Poids = @Poids,
        Taille = @Taille,
        GroupeSanguin = @GroupeSanguin
    WHERE IdPatient = @IdPatient;

    SELECT 'Patient updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeletePatient
    @IdPatient INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Patient
    WHERE IdPatient = @IdPatient;

    SELECT 'Patient deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetPatientById
    @IdPatient INT
AS
BEGIN
    SELECT IdPatient, IdRegion, Nom, Prenom, DateNaissance, Sexe, Structure, Adresse, Telephone, Email, Poids, Taille, GroupeSanguin, DateInscription
    FROM Patient
    WHERE IdPatient = @IdPatient;
END;
GO

CREATE PROCEDURE GetPatientsAll
AS
BEGIN
    SELECT IdPatient, IdRegion, Nom, Prenom, DateNaissance, Sexe, Structure, Adresse, Telephone, Email, Poids, Taille, GroupeSanguin, DateInscription,Age
	FROM Patient;
END;
GO
CREATE PROCEDURE CreateMedecin
    @IdMedecin INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Medecin WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Medecin (IdMedecin, Nom, Prenom, Telephone, Email)
    VALUES (@IdMedecin, @Nom, @Prenom, @Telephone, @Email);

    SELECT 'Medecin created successfully.' AS Message;
END;
GO

CREATE PROCEDURE UpdateMedecin
    @IdMedecin INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Medecin
    SET
        Nom = @Nom,
        Prenom = @Prenom,
        Telephone = @Telephone,
        Email = @Email
    WHERE IdMedecin = @IdMedecin;

    SELECT 'Medecin updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteMedecin
    @IdMedecin INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Medecin
    WHERE IdMedecin = @IdMedecin;

    SELECT 'Medecin deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetMedecinById
    @IdMedecin INT
AS
BEGIN
    SELECT IdMedecin, Nom, Prenom, Telephone, Email
    FROM Medecin
    WHERE IdMedecin = @IdMedecin;
END;
GO

CREATE PROCEDURE GetAllMedecins
AS
BEGIN
    SELECT IdMedecin, Nom, Prenom,FullName, Telephone, Email 
    FROM Medecin;
END;
GO

CREATE PROCEDURE CreateAssistant
    @IdAssistant INT,
    @IdMedecin INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Assistant WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Assistant (IdAssistant, IdMedecin, Nom, Prenom, Telephone, Email)
    VALUES (@IdAssistant, @IdMedecin, @Nom, @Prenom, @Telephone, @Email);

    SELECT 'Assistant created successfully.' AS Message;
END;
GO

CREATE PROCEDURE UpdateAssistant
    @IdAssistant INT,
    @IdMedecin INT,
    @Nom NVARCHAR(100),
    @Prenom NVARCHAR(100),
    @Telephone NVARCHAR(20),
    @Email NVARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Assistant WHERE IdAssistant = @IdAssistant)
    BEGIN
        RAISERROR('Assistant does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Assistant
    SET
        IdMedecin = @IdMedecin,
        Nom = @Nom,
        Prenom = @Prenom,
        Telephone = @Telephone,
        Email = @Email
    WHERE IdAssistant = @IdAssistant;

    SELECT 'Assistant updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteAssistant
    @IdAssistant INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Assistant WHERE IdAssistant = @IdAssistant)
    BEGIN
        RAISERROR('Assistant does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Assistant
    WHERE IdAssistant = @IdAssistant;

    SELECT 'Assistant deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetAssistantById
    @IdAssistant INT
AS
BEGIN
    SELECT IdAssistant, IdMedecin, Nom, Prenom, Telephone, Email
    FROM Assistant
    WHERE IdAssistant = @IdAssistant;
END;
GO

CREATE PROCEDURE ListAllAssistants
AS
BEGIN
    SELECT IdAssistant, IdMedecin, Nom, Prenom, Telephone, Email
    FROM Assistant;
END;
GO

CREATE PROCEDURE CreateMedicament
    @NomMedicament NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Dosage NVARCHAR(100),
    @FormePharmaceutique NVARCHAR(100),
    @StockDisponible INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Medicament WHERE NomMedicament = @NomMedicament)
    BEGIN
        RAISERROR('Medicament name already exists.', 16, 1);
        RETURN;
    END

	INSERT INTO Medicament (NomMedicament, Description, Dosage, FormePharmaceutique, StockDisponible)
    VALUES (@NomMedicament, @Description, @Dosage, @FormePharmaceutique, @StockDisponible);

    SELECT SCOPE_IDENTITY() AS IdMedicament;
END;
GO

CREATE PROCEDURE UpdateMedicament
    @IdMedicament INT,
    @NomMedicament NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Dosage NVARCHAR(100),
    @FormePharmaceutique NVARCHAR(100),
    @StockDisponible INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medicament WHERE IdMedicament = @IdMedicament)
    BEGIN
        RAISERROR('Medicament does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Medicament
    SET
        NomMedicament = @NomMedicament,
        Description = @Description,
        Dosage = @Dosage,
        FormePharmaceutique = @FormePharmaceutique,
        StockDisponible = @StockDisponible
    WHERE IdMedicament = @IdMedicament;

    SELECT 'Medicament updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteMedicament
    @IdMedicament INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medicament WHERE IdMedicament = @IdMedicament)
    BEGIN
        RAISERROR('Medicament does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Medicament
    WHERE IdMedicament = @IdMedicament;

    SELECT 'Medicament deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetMedicamentById
    @IdMedicament INT
AS
BEGIN
    SELECT IdMedicament, NomMedicament, Description, Dosage, FormePharmaceutique, StockDisponible, DateAjout
    FROM Medicament
    WHERE IdMedicament = @IdMedicament;
END;
GO

CREATE PROCEDURE ListAllMedicaments
AS
BEGIN
    SELECT IdMedicament, NomMedicament, Description, Dosage, FormePharmaceutique, StockDisponible, DateAjout
    FROM Medicament;
END;
GO

CREATE PROCEDURE CreateStock
    @IdMedicament INT,
    @Quantite INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medicament WHERE IdMedicament = @IdMedicament)
    BEGIN
        RAISERROR('Medicament does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO Stock (IdMedicament, Quantite)
    VALUES (@IdMedicament, @Quantite);

    SELECT SCOPE_IDENTITY() AS IdStock;
END;
GO

CREATE PROCEDURE UpdateStock
    @IdStock INT,
    @IdMedicament INT,
    @Quantite INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Stock WHERE IdStock = @IdStock)
    BEGIN
        RAISERROR('Stock does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Stock
    SET
        IdMedicament = @IdMedicament,
        Quantite = @Quantite
    WHERE IdStock = @IdStock;

    SELECT 'Stock updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteStock
    @IdStock INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Stock WHERE IdStock = @IdStock)
    BEGIN
        RAISERROR('Stock does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Stock
    WHERE IdStock = @IdStock;

    SELECT 'Stock deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetStockById
    @IdStock INT
AS
BEGIN
    SELECT IdStock, IdMedicament, Quantite
    FROM Stock
    WHERE IdStock = @IdStock;
END;
GO

CREATE PROCEDURE ListAllStocks
AS
BEGIN
    SELECT IdStock, IdMedicament, Quantite
    FROM Stock;
END;
GO

CREATE PROCEDURE CreateStockMovement
    @IdStock INT,
    @TypeMouvement NVARCHAR(50),
    @QuantiteMouvement INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Stock WHERE IdStock = @IdStock)
    BEGIN
        RAISERROR('Stock does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO StockMovement (IdStock, TypeMouvement, QuantiteMouvement)
    VALUES (@IdStock, @TypeMouvement, @QuantiteMouvement);

    SELECT SCOPE_IDENTITY() AS IdMovement;
END;
GO

CREATE PROCEDURE UpdateStockMovement
    @IdMovement INT,
    @IdStock INT,
    @TypeMouvement NVARCHAR(50),
    @QuantiteMouvement INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM StockMovement WHERE IdMovement = @IdMovement)
    BEGIN
        RAISERROR('Stock movement does not exist.', 16, 1);
        RETURN;
    END

    UPDATE StockMovement
    SET
        IdStock = @IdStock,
        TypeMouvement = @TypeMouvement,
        QuantiteMouvement = @QuantiteMouvement
    WHERE IdMovement = @IdMovement;

    SELECT 'Stock movement updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteStockMovement
    @IdMovement INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM StockMovement WHERE IdMovement = @IdMovement)
    BEGIN
        RAISERROR('Stock movement does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM StockMovement
    WHERE IdMovement = @IdMovement;

    SELECT 'Stock movement deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetStockMovementById
    @IdMovement INT
AS
BEGIN
    SELECT IdMovement, IdStock, TypeMouvement, QuantiteMouvement, DateMouvement
    FROM StockMovement
    WHERE IdMovement = @IdMovement;
END;
GO

CREATE PROCEDURE ListAllStockMovements
AS
BEGIN
    SELECT IdMovement, IdStock, TypeMouvement, QuantiteMouvement, DateMouvement
    FROM StockMovement;
END;
GO

CREATE PROCEDURE CreateConsultation
    @IdPatient INT,
    @IdMedecin INT,
    @Diagnostic NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO Consultation (IdPatient, IdMedecin, Diagnostic, Remarques)
    VALUES (@IdPatient, @IdMedecin, @Diagnostic, @Remarques);

    SELECT SCOPE_IDENTITY() AS IdConsultation;
END;
GO

CREATE PROCEDURE UpdateConsultation
    @IdConsultation INT,
    @IdPatient INT,
    @IdMedecin INT,
    @Diagnostic NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Consultation WHERE IdConsultation = @IdConsultation)
    BEGIN
        RAISERROR('Consultation does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Consultation
    SET
        IdPatient = @IdPatient,
        IdMedecin = @IdMedecin,
        Diagnostic = @Diagnostic,
        Remarques = @Remarques
    WHERE IdConsultation = @IdConsultation;

    SELECT 'Consultation updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteConsultation
    @IdConsultation INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Consultation WHERE IdConsultation = @IdConsultation)
    BEGIN
        RAISERROR('Consultation does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Consultation
    WHERE IdConsultation = @IdConsultation;

    SELECT 'Consultation deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetConsultationById
    @IdConsultation INT
AS
BEGIN
    SELECT IdConsultation, IdPatient, IdMedecin, DateConsultation, Diagnostic, Remarques
    FROM Consultation
    WHERE IdConsultation = @IdConsultation;
END;
GO

CREATE PROCEDURE ListAllConsultations
AS
BEGIN
    SELECT IdConsultation, IdPatient, IdMedecin, DateConsultation, Diagnostic, Remarques
    FROM Consultation;
END;
GO

CREATE PROCEDURE CreateHistoriqueConsultation
    @IdConsultation INT,
    @IdPatient INT,
    @IdMedecin INT,
    @DateConsultation DATETIME,
    @Diagnostic NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Consultation WHERE IdConsultation = @IdConsultation)
    BEGIN
        RAISERROR('Consultation does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO HistoriqueConsultations (IdConsultation, IdPatient, IdMedecin, DateConsultation, Diagnostic, Remarques)
    VALUES (@IdConsultation, @IdPatient, @IdMedecin, @DateConsultation, @Diagnostic, @Remarques);

    SELECT SCOPE_IDENTITY() AS IdHistorique;
END;
GO

CREATE PROCEDURE UpdateHistoriqueConsultation
    @IdHistorique INT,
    @IdConsultation INT,
    @IdPatient INT,
    @IdMedecin INT,
    @DateConsultation DATETIME,
    @Diagnostic NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HistoriqueConsultations WHERE IdHistorique = @IdHistorique)
    BEGIN
        RAISERROR('Historique consultation does not exist.', 16, 1);
        RETURN;
    END

    UPDATE HistoriqueConsultations
    SET
        IdConsultation = @IdConsultation,
        IdPatient = @IdPatient,
        IdMedecin = @IdMedecin,
        DateConsultation = @DateConsultation,
        Diagnostic = @Diagnostic,
        Remarques = @Remarques
    WHERE IdHistorique = @IdHistorique;

    SELECT 'Historique consultation updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteHistoriqueConsultation
    @IdHistorique INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HistoriqueConsultations WHERE IdHistorique = @IdHistorique)
    BEGIN
        RAISERROR('Historique consultation does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM HistoriqueConsultations
    WHERE IdHistorique = @IdHistorique;

    SELECT 'Historique consultation deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetHistoriqueConsultationById
    @IdHistorique INT
AS
BEGIN
    SELECT IdHistorique, IdConsultation, IdPatient, IdMedecin, DateConsultation, Diagnostic, Remarques
    FROM HistoriqueConsultations
    WHERE IdHistorique = @IdHistorique;
END;
GO

CREATE PROCEDURE ListAllHistoriqueConsultations
AS
BEGIN
    SELECT IdHistorique, IdConsultation, IdPatient, IdMedecin, DateConsultation, Diagnostic, Remarques
    FROM HistoriqueConsultations;
END;
GO

CREATE PROCEDURE CreateOrdonnance
    @IdPatient INT,
    @IdMedecin INT,
    @Instructions NVARCHAR(MAX),
    @IdConsultation INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO Ordonnance (IdPatient, IdMedecin, Instructions, IdConsultation)
    VALUES (@IdPatient, @IdMedecin, @Instructions, @IdConsultation);

    SELECT SCOPE_IDENTITY() AS IdOrdonnance;
END;
GO

CREATE PROCEDURE UpdateOrdonnance
    @IdOrdonnance INT,
    @IdPatient INT,
    @IdMedecin INT,
    @Instructions NVARCHAR(MAX),
    @IdConsultation INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Ordonnance WHERE IdOrdonnance = @IdOrdonnance)
    BEGIN
        RAISERROR('Ordonnance does not exist.', 16, 1);
        RETURN;
    END

    UPDATE Ordonnance
    SET
        IdPatient = @IdPatient,
        IdMedecin = @IdMedecin,
        Instructions = @Instructions,
        IdConsultation = @IdConsultation
    WHERE IdOrdonnance = @IdOrdonnance;

    SELECT 'Ordonnance updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteOrdonnance
    @IdOrdonnance INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Ordonnance WHERE IdOrdonnance = @IdOrdonnance)
    BEGIN
        RAISERROR('Ordonnance does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM Ordonnance
    WHERE IdOrdonnance = @IdOrdonnance;

    SELECT 'Ordonnance deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetOrdonnanceById
    @IdOrdonnance INT
AS
BEGIN
    SELECT IdOrdonnance, IdPatient, IdMedecin, DateOrdonnance, Instructions, IdConsultation
    FROM Ordonnance
    WHERE IdOrdonnance = @IdOrdonnance;
END;
GO

CREATE PROCEDURE ListAllOrdonnances
AS
BEGIN
    SELECT IdOrdonnance, IdPatient, IdMedecin, DateOrdonnance, Instructions, IdConsultation
    FROM Ordonnance;
END;
GO

CREATE PROCEDURE CreateVisitePeriodique
    @IdPatient INT,
    @IdMedecin INT,
    @DateHeureVisite DATETIME,
    @TypeVisite NVARCHAR(50),
    @Motif NVARCHAR(MAX),
    @Statut NVARCHAR(50),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO VisitePeriodique (IdPatient, IdMedecin, DateHeureVisite, TypeVisite, Motif, Statut, Remarques)
    VALUES (@IdPatient, @IdMedecin, @DateHeureVisite, @TypeVisite, @Motif, @Statut, @Remarques);

    SELECT SCOPE_IDENTITY() AS IdVisite;
END;
GO

CREATE PROCEDURE UpdateVisitePeriodique
    @IdVisite INT,
    @IdPatient INT,
    @IdMedecin INT,
    @DateHeureVisite DATETIME,
    @TypeVisite NVARCHAR(50),
    @Motif NVARCHAR(MAX),
    @Statut NVARCHAR(50),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM VisitePeriodique WHERE IdVisite = @IdVisite)
    BEGIN
        RAISERROR('Visite periodique does not exist.', 16, 1);
        RETURN;
    END

    UPDATE VisitePeriodique
    SET
        IdPatient = @IdPatient,
        IdMedecin = @IdMedecin,
        DateHeureVisite = @DateHeureVisite,
        TypeVisite = @TypeVisite,
        Motif = @Motif,
        Statut = @Statut,
        Remarques = @Remarques
    WHERE IdVisite = @IdVisite;

    SELECT 'Visite periodique updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteVisitePeriodique
    @IdVisite INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM VisitePeriodique WHERE IdVisite = @IdVisite)
    BEGIN
        RAISERROR('Visite periodique does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM VisitePeriodique
    WHERE IdVisite = @IdVisite;

    SELECT 'Visite periodique deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetVisitePeriodiqueById
    @IdVisite INT
AS
BEGIN
    SELECT IdVisite, IdPatient, IdMedecin, DateHeureVisite, TypeVisite, Motif, Statut, Remarques
    FROM VisitePeriodique
    WHERE IdVisite = @IdVisite;
END;
GO

CREATE PROCEDURE ListAllVisitesPeriodiques
AS
BEGIN
    SELECT IdVisite, IdPatient, IdMedecin, DateHeureVisite, TypeVisite, Motif, Statut, Remarques
    FROM VisitePeriodique;
END;
GO

CREATE PROCEDURE CreateMaladieChronique
    @NomMaladie NVARCHAR(255),
    @Description NVARCHAR(MAX)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM MaladieChronique WHERE NomMaladie = @NomMaladie)
    BEGIN
        RAISERROR('Maladie chronique name already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO MaladieChronique (NomMaladie, Description)
    VALUES (@NomMaladie, @Description);

    SELECT SCOPE_IDENTITY() AS IdMaladie;
END;
GO

CREATE PROCEDURE UpdateMaladieChronique
    @IdMaladie INT,
    @NomMaladie NVARCHAR(255),
    @Description NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MaladieChronique WHERE IdMaladie = @IdMaladie)
    BEGIN
        RAISERROR('Maladie chronique does not exist.', 16, 1);
        RETURN;
    END

    UPDATE MaladieChronique
    SET
        NomMaladie = @NomMaladie,
        Description = @Description
    WHERE IdMaladie = @IdMaladie;

    SELECT 'Maladie chronique updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteMaladieChronique
    @IdMaladie INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MaladieChronique WHERE IdMaladie = @IdMaladie)
    BEGIN
        RAISERROR('Maladie chronique does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM MaladieChronique
    WHERE IdMaladie = @IdMaladie;

    SELECT 'Maladie chronique deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetMaladieChroniqueById
    @IdMaladie INT
AS
BEGIN
    SELECT IdMaladie, NomMaladie, Description
    FROM MaladieChronique
    WHERE IdMaladie = @IdMaladie;
END;
GO

CREATE PROCEDURE ListAllMaladiesChroniques
AS
BEGIN
    SELECT IdMaladie, NomMaladie, Description
    FROM MaladieChronique;
END;
GO

CREATE PROCEDURE CreateDossierMedical
    @IdPatient INT,
    @IdMaladie INT,
    @Allergies NVARCHAR(MAX),
    @TraitementsActuels NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MaladieChronique WHERE IdMaladie = @IdMaladie)
    BEGIN
        RAISERROR('Maladie chronique does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO DossierMedical (IdPatient, IdMaladie, Allergies, TraitementsActuels, Remarques)
    VALUES (@IdPatient, @IdMaladie, @Allergies, @TraitementsActuels, @Remarques);

    SELECT SCOPE_IDENTITY() AS IdDossier;
END;
GO

CREATE PROCEDURE UpdateDossierMedical
    @IdDossier INT,
    @IdPatient INT,
    @IdMaladie INT,
    @Allergies NVARCHAR(MAX),
    @TraitementsActuels NVARCHAR(MAX),
    @Remarques NVARCHAR(MAX)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DossierMedical WHERE IdDossier = @IdDossier)
    BEGIN
        RAISERROR('Dossier medical does not exist.', 16, 1);
        RETURN;
    END

    UPDATE DossierMedical
    SET
        IdPatient = @IdPatient,
        IdMaladie = @IdMaladie,
        Allergies = @Allergies,
        TraitementsActuels = @TraitementsActuels,
        Remarques = @Remarques
    WHERE IdDossier = @IdDossier;

    SELECT 'Dossier medical updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteDossierMedical
    @IdDossier INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DossierMedical WHERE IdDossier = @IdDossier)
    BEGIN
        RAISERROR('Dossier medical does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM DossierMedical
    WHERE IdDossier = @IdDossier;

    SELECT 'Dossier medical deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetDossierMedicalById
    @IdDossier INT
AS
BEGIN
    SELECT IdDossier, IdPatient, IdMaladie, DateCreation, Allergies, TraitementsActuels, Remarques
    FROM DossierMedical
    WHERE IdDossier = @IdDossier;
END;
GO

CREATE PROCEDURE ListAllDossiersMedicaux
AS
BEGIN
    SELECT IdDossier, IdPatient, IdMaladie, DateCreation, Allergies, TraitementsActuels, Remarques
    FROM DossierMedical;
END;
GO

CREATE PROCEDURE CreateCasSpecial
    @NomCas NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM CasSpecial WHERE NomCas = @NomCas)
    BEGIN
        RAISERROR('Cas special name already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO CasSpecial (NomCas)
    VALUES (@NomCas);

    SELECT SCOPE_IDENTITY() AS IdCas;
END;
GO

CREATE PROCEDURE UpdateCasSpecial
    @IdCas INT,
    @NomCas NVARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CasSpecial WHERE IdCas = @IdCas)
    BEGIN
        RAISERROR('Cas special does not exist.', 16, 1);
        RETURN;
    END

    UPDATE CasSpecial
    SET
        NomCas = @NomCas
    WHERE IdCas = @IdCas;

    SELECT 'Cas special updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteCasSpecial
    @IdCas INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CasSpecial WHERE IdCas = @IdCas)
    BEGIN
        RAISERROR('Cas special does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM CasSpecial
    WHERE IdCas = @IdCas;

    SELECT 'Cas special deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetCasSpecialById
    @IdCas INT
AS
BEGIN
    SELECT IdCas, NomCas
    FROM CasSpecial
    WHERE IdCas = @IdCas;
END;
GO

CREATE PROCEDURE ListAllCasSpecials
AS
BEGIN
    SELECT IdCas, NomCas
    FROM CasSpecial;
END;
GO

CREATE PROCEDURE CreateOrdonnanceMedicament
    @IdOrdonnance INT,
    @IdMedicament INT,
    @Description NVARCHAR(MAX),
    @DureeTraitement INT,
    @Frequence INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Ordonnance WHERE IdOrdonnance = @IdOrdonnance)
    BEGIN
        RAISERROR('Ordonnance does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Medicament WHERE IdMedicament = @IdMedicament)
    BEGIN
        RAISERROR('Medicament does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO OrdonnanceMedicament (IdOrdonnance, IdMedicament, Description, DureeTraitement, Frequence)
    VALUES (@IdOrdonnance, @IdMedicament, @Description, @DureeTraitement, @Frequence);

    SELECT SCOPE_IDENTITY() AS IdOrdonnanceMedicament;
END;
GO

CREATE PROCEDURE UpdateOrdonnanceMedicament
    @IdOrdonnanceMedicament INT,
    @IdOrdonnance INT,
    @IdMedicament INT,
    @Description NVARCHAR(MAX),
    @DureeTraitement INT,
    @Frequence INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM OrdonnanceMedicament WHERE IdOrdonnanceMedicament = @IdOrdonnanceMedicament)
    BEGIN
        RAISERROR('Ordonnance medicament does not exist.', 16, 1);
        RETURN;
    END

    UPDATE OrdonnanceMedicament
    SET
        IdOrdonnance = @IdOrdonnance,
        IdMedicament = @IdMedicament,
        Description = @Description,
        DureeTraitement = @DureeTraitement,
        Frequence = @Frequence
    WHERE IdOrdonnanceMedicament = @IdOrdonnanceMedicament;

    SELECT 'Ordonnance medicament updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteOrdonnanceMedicament
    @IdOrdonnanceMedicament INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM OrdonnanceMedicament WHERE IdOrdonnanceMedicament = @IdOrdonnanceMedicament)
    BEGIN
        RAISERROR('Ordonnance medicament does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM OrdonnanceMedicament
    WHERE IdOrdonnanceMedicament = @IdOrdonnanceMedicament;

    SELECT 'Ordonnance medicament deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetOrdonnanceMedicamentById
    @IdOrdonnanceMedicament INT
AS
BEGIN
    SELECT IdOrdonnanceMedicament, IdOrdonnance, IdMedicament, Description, DureeTraitement, Frequence
    FROM OrdonnanceMedicament
    WHERE IdOrdonnanceMedicament = @IdOrdonnanceMedicament;
END;
GO

CREATE PROCEDURE ListAllOrdonnanceMedicaments
AS
BEGIN
    SELECT IdOrdonnanceMedicament, IdOrdonnance, IdMedicament, Description, DureeTraitement, Frequence
    FROM OrdonnanceMedicament;
END;
GO

CREATE PROCEDURE CreateBilanDetails
    @FNS BIT,
    @VS BIT,
    @GlycemieJeun BIT,
    @UreeSanguin BIT,
    @CreatinineSanguine BIT,
    @CholesterolTotal BIT,
    @HDLChol BIT,
    @LDLChol BIT,
    @TG BIT,
    @ASAT BIT,
    @ALAT BIT,
    @YGT BIT,
    @PhosphataseAlcaline BIT,
    @TSH BIT,
    @FT3 BIT,
    @FT4 BIT,
    @FerSerique BIT,
    @Microalbuminurie BIT,
    @ECBU BIT,
    @Fibrinogene BIT,
    @CRP BIT,
    @WallerRose BIT,
    @Latex BIT,
    @VitD3 BIT,
    @HbA1C BIT,
    @Calcemie BIT,
    @Phosphoremie BIT,
    @IonogrammeSanguin BIT,
    @BilirubineIndirecte BIT,
    @BilirubineTotale BIT,
    @BilirubineDirecte BIT,
    @Amylasemie BIT,
    @AcideUrique BIT,
    @PSATotaux BIT,
    @PSALibres BIT,
    @ChimieUrines BIT,
    @Ferritinemie BIT
AS
BEGIN
    INSERT INTO BilanDetails (
        FNS, VS, GlycemieJeun, UreeSanguin, CreatinineSanguine, CholesterolTotal, HDLChol, LDLChol, TG, ASAT, ALAT, YGT,
        PhosphataseAlcaline, TSH, FT3, FT4, FerSerique, Microalbuminurie, ECBU, Fibrinogene, CRP, WallerRose, Latex, VitD3,
        HbA1C, Calcemie, Phosphoremie, IonogrammeSanguin, BilirubineIndirecte, BilirubineTotale, BilirubineDirecte, Amylasemie,
        AcideUrique, PSATotaux, PSALibres, ChimieUrines, Ferritinemie
    )
    VALUES (
        @FNS, @VS, @GlycemieJeun, @UreeSanguin, @CreatinineSanguine, @CholesterolTotal, @HDLChol, @LDLChol, @TG, @ASAT, @ALAT, @YGT,
        @PhosphataseAlcaline, @TSH, @FT3, @FT4, @FerSerique, @Microalbuminurie, @ECBU, @Fibrinogene, @CRP, @WallerRose, @Latex, @VitD3,
        @HbA1C, @Calcemie, @Phosphoremie, @IonogrammeSanguin, @BilirubineIndirecte, @BilirubineTotale, @BilirubineDirecte, @Amylasemie,
        @AcideUrique, @PSATotaux, @PSALibres, @ChimieUrines, @Ferritinemie
    );

    SELECT SCOPE_IDENTITY() AS IdBilanDetails;
END;
GO

CREATE PROCEDURE UpdateBilanDetails
    @IdBilanDetails INT,
    @FNS BIT,
    @VS BIT,
    @GlycemieJeun BIT,
    @UreeSanguin BIT,
    @CreatinineSanguine BIT,
    @CholesterolTotal BIT,
    @HDLChol BIT,
    @LDLChol BIT,
    @TG BIT,
    @ASAT BIT,
    @ALAT BIT,
    @YGT BIT,
    @PhosphataseAlcaline BIT,
    @TSH BIT,
    @FT3 BIT,
    @FT4 BIT,
    @FerSerique BIT,
    @Microalbuminurie BIT,
    @ECBU BIT,
    @Fibrinogene BIT,
    @CRP BIT,
    @WallerRose BIT,
    @Latex BIT,
    @VitD3 BIT,
    @HbA1C BIT,
    @Calcemie BIT,
    @Phosphoremie BIT,
    @IonogrammeSanguin BIT,
    @BilirubineIndirecte BIT,
    @BilirubineTotale BIT,
    @BilirubineDirecte BIT,
    @Amylasemie BIT,
    @AcideUrique BIT,
    @PSATotaux BIT,
    @PSALibres BIT,
    @ChimieUrines BIT,
    @Ferritinemie BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BilanDetails WHERE IdBilanDetails = @IdBilanDetails)
    BEGIN
        RAISERROR('Bilan details do not exist.', 16, 1);
        RETURN;
    END

    UPDATE BilanDetails
    SET
        FNS = @FNS,
        VS = @VS,
        GlycemieJeun = @GlycemieJeun,
        UreeSanguin = @UreeSanguin,
        CreatinineSanguine = @CreatinineSanguine,
        CholesterolTotal = @CholesterolTotal,
        HDLChol = @HDLChol,
        LDLChol = @LDLChol,
        TG = @TG,
        ASAT = @ASAT,
        ALAT = @ALAT,
        YGT = @YGT,
        PhosphataseAlcaline = @PhosphataseAlcaline,
        TSH = @TSH,
        FT3 = @FT3,
        FT4 = @FT4,
        FerSerique = @FerSerique,
        Microalbuminurie = @Microalbuminurie,
        ECBU = @ECBU,
        Fibrinogene = @Fibrinogene,
        CRP = @CRP,
        WallerRose = @WallerRose,
        Latex = @Latex,
        VitD3 = @VitD3,
        HbA1C = @HbA1C,
        Calcemie = @Calcemie,
        Phosphoremie = @Phosphoremie,
        IonogrammeSanguin = @IonogrammeSanguin,
        BilirubineIndirecte = @BilirubineIndirecte,
        BilirubineTotale = @BilirubineTotale,
        BilirubineDirecte = @BilirubineDirecte,
        Amylasemie = @Amylasemie,
        AcideUrique = @AcideUrique,
        PSATotaux = @PSATotaux,
        PSALibres = @PSALibres,
        ChimieUrines = @ChimieUrines,
        Ferritinemie = @Ferritinemie
    WHERE IdBilanDetails = @IdBilanDetails;

    SELECT 'Bilan details updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteBilanDetails
    @IdBilanDetails INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BilanDetails WHERE IdBilanDetails = @IdBilanDetails)
    BEGIN
        RAISERROR('Bilan details do not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM BilanDetails
    WHERE IdBilanDetails = @IdBilanDetails;

    SELECT 'Bilan details deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetBilanDetailsById
    @IdBilanDetails INT
AS
BEGIN
    SELECT *
    FROM BilanDetails
    WHERE IdBilanDetails = @IdBilanDetails;
END;
GO

CREATE PROCEDURE ListAllBilanDetails
AS
BEGIN
    SELECT *
    FROM BilanDetails;
END;
GO

CREATE PROCEDURE CreateBilanBiologique
    @IdBilanDetails INT,
    @IdPatient INT,
    @VisaMedecin NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BilanDetails WHERE IdBilanDetails = @IdBilanDetails)
    BEGIN
        RAISERROR('Bilan details do not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO BilanBiologique (IdBilanDetails, IdPatient, VisaMedecin)
    VALUES (@IdBilanDetails, @IdPatient, @VisaMedecin);

    SELECT SCOPE_IDENTITY() AS IdBilan;
END;
GO

CREATE PROCEDURE UpdateBilanBiologique
    @IdBilan INT,
    @IdBilanDetails INT,
    @IdPatient INT,
    @VisaMedecin NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BilanBiologique WHERE IdBilan = @IdBilan)
    BEGIN
        RAISERROR('Bilan biologique does not exist.', 16, 1);
        RETURN;
    END

    UPDATE BilanBiologique
    SET
        IdBilanDetails = @IdBilanDetails,
        IdPatient = @IdPatient,
        VisaMedecin = @VisaMedecin
    WHERE IdBilan = @IdBilan;

    SELECT 'Bilan biologique updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteBilanBiologique
    @IdBilan INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BilanBiologique WHERE IdBilan = @IdBilan)
    BEGIN
        RAISERROR('Bilan biologique does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM BilanBiologique
    WHERE IdBilan = @IdBilan;

    SELECT 'Bilan biologique deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetBilanBiologiqueById
    @IdBilan INT
AS
BEGIN
    SELECT IdBilan, IdBilanDetails, IdPatient, DateExamen, VisaMedecin
    FROM BilanBiologique
    WHERE IdBilan = @IdBilan;
END;
GO

CREATE PROCEDURE ListAllBilanBiologiques
AS
BEGIN
    SELECT IdBilan, IdBilanDetails, IdPatient, DateExamen, VisaMedecin
    FROM BilanBiologique;
END;
GO

CREATE PROCEDURE CreateCertificatArretTravail
    @IdMedecin INT,
    @IdPatient INT,
    @IdConsultation INT,
    @JoursArret INT,
    @DateDebut DATE,
    @ProlongationJours INT,
    @DateProlongation DATE,
    @DateCertificat DATE,
    @DateFin DATE,
    @Lieu NVARCHAR(100),
    @Motif NVARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Consultation WHERE IdConsultation = @IdConsultation)
    BEGIN
        RAISERROR('Consultation does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO CertificatArretTravail (
        IdMedecin, IdPatient, IdConsultation, JoursArret, DateDebut, ProlongationJours, DateProlongation, DateCertificat, DateFin, Lieu, Motif
    )
    VALUES (
        @IdMedecin, @IdPatient, @IdConsultation, @JoursArret, @DateDebut, @ProlongationJours, @DateProlongation, @DateCertificat, @DateFin, @Lieu, @Motif
    );

    SELECT SCOPE_IDENTITY() AS IdCertificat;
END;
GO

CREATE PROCEDURE UpdateCertificatArretTravail
    @IdCertificat INT,
    @IdMedecin INT,
    @IdPatient INT,
    @IdConsultation INT,
    @JoursArret INT,
    @DateDebut DATE,
    @ProlongationJours INT,
    @DateProlongation DATE,
    @DateCertificat DATE,
    @DateFin DATE,
    @Lieu NVARCHAR(100),
    @Motif NVARCHAR(255)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CertificatArretTravail WHERE IdCertificat = @IdCertificat)
    BEGIN
        RAISERROR('Certificat arret travail does not exist.', 16, 1);
        RETURN;
    END

    UPDATE CertificatArretTravail
    SET
        IdMedecin = @IdMedecin,
        IdPatient = @IdPatient,
        IdConsultation = @IdConsultation,
        JoursArret = @JoursArret,
        DateDebut = @DateDebut,
        ProlongationJours = @ProlongationJours,
        DateProlongation = @DateProlongation,
        DateCertificat = @DateCertificat,
        DateFin = @DateFin,
        Lieu = @Lieu,
        Motif = @Motif
    WHERE IdCertificat = @IdCertificat;

    SELECT 'Certificat arret travail updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteCertificatArretTravail
    @IdCertificat INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CertificatArretTravail WHERE IdCertificat = @IdCertificat)
    BEGIN
        RAISERROR('Certificat arret travail does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM CertificatArretTravail
    WHERE IdCertificat = @IdCertificat;

    SELECT 'Certificat arret travail deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetCertificatArretTravailById
    @IdCertificat INT
AS
BEGIN
    SELECT IdCertificat, IdMedecin, IdPatient, IdConsultation, JoursArret, DateDebut, ProlongationJours, DateProlongation, DateCertificat, DateFin, Lieu, Motif
    FROM CertificatArretTravail
    WHERE IdCertificat = @IdCertificat;
END;
GO

CREATE PROCEDURE ListAllCertificatsArretTravail
AS
BEGIN
    SELECT IdCertificat, IdMedecin, IdPatient, IdConsultation, JoursArret, DateDebut, ProlongationJours, DateProlongation, DateCertificat, DateFin, Lieu, Motif
    FROM CertificatArretTravail;
END;
GO

CREATE PROCEDURE CreateCertificatAptitude
    @IdMedecin INT,
    @IdPatient INT,
    @TypeVisite NVARCHAR(50),
    @PosteFonction NVARCHAR(100),
    @Aptitude NVARCHAR(50),
    @JoursInaptitude INT,
    @DateCertificat DATE,
    @Lieu NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medecin WHERE IdMedecin = @IdMedecin)
    BEGIN
        RAISERROR('Medecin does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO CertificatAptitude (
        IdMedecin, IdPatient, TypeVisite, PosteFonction, Aptitude, JoursInaptitude, DateCertificat, Lieu
    )
    VALUES (
        @IdMedecin, @IdPatient, @TypeVisite, @PosteFonction, @Aptitude, @JoursInaptitude, @DateCertificat, @Lieu
    );

    SELECT SCOPE_IDENTITY() AS IdCertificat;
END;
GO

CREATE PROCEDURE UpdateCertificatAptitude
    @IdCertificat INT,
    @IdMedecin INT,
    @IdPatient INT,
    @TypeVisite NVARCHAR(50),
    @PosteFonction NVARCHAR(100),
    @Aptitude NVARCHAR(50),
    @JoursInaptitude INT,
    @DateCertificat DATE,
    @Lieu NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CertificatAptitude WHERE IdCertificat = @IdCertificat)
    BEGIN
        RAISERROR('Certificat aptitude does not exist.', 16, 1);
        RETURN;
    END

    UPDATE CertificatAptitude
    SET
        IdMedecin = @IdMedecin,
        IdPatient = @IdPatient,
        TypeVisite = @TypeVisite,
        PosteFonction = @PosteFonction,
        Aptitude = @Aptitude,
        JoursInaptitude = @JoursInaptitude,
        DateCertificat = @DateCertificat,
        Lieu = @Lieu
    WHERE IdCertificat = @IdCertificat;

    SELECT 'Certificat aptitude updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteCertificatAptitude
    @IdCertificat INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CertificatAptitude WHERE IdCertificat = @IdCertificat)
    BEGIN
        RAISERROR('Certificat aptitude does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM CertificatAptitude
    WHERE IdCertificat = @IdCertificat;

    SELECT 'Certificat aptitude deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetCertificatAptitudeById
    @IdCertificat INT
AS
BEGIN
    SELECT IdCertificat, IdMedecin, IdPatient, TypeVisite, PosteFonction, Aptitude, JoursInaptitude, DateCertificat, Lieu
    FROM CertificatAptitude
    WHERE IdCertificat = @IdCertificat;
END;
GO

CREATE PROCEDURE ListAllCertificatsAptitude
AS
BEGIN
    SELECT IdCertificat, IdMedecin, IdPatient, TypeVisite, PosteFonction, Aptitude, JoursInaptitude, DateCertificat, Lieu
    FROM CertificatAptitude;
END;
GO

CREATE PROCEDURE CreateLettreOrientation
    @IdPatient INT,
    @Profession NVARCHAR(100),
    @Antecedents NVARCHAR(MAX),
    @Symptomes NVARCHAR(MAX),
    @TypeOrientation NVARCHAR(50),
    @Lieu NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE IdPatient = @IdPatient)
    BEGIN
        RAISERROR('Patient does not exist.', 16, 1);
        RETURN;
    END

    INSERT INTO LettreOrientation (IdPatient, Profession, Antecedents, Symptomes, TypeOrientation, Lieu)
    VALUES (@IdPatient, @Profession, @Antecedents, @Symptomes, @TypeOrientation, @Lieu);

    SELECT SCOPE_IDENTITY() AS IdOrientation;
END;
GO

CREATE PROCEDURE UpdateLettreOrientation
    @IdOrientation INT,
    @IdPatient INT,
    @Profession NVARCHAR(100),
    @Antecedents NVARCHAR(MAX),
    @Symptomes NVARCHAR(MAX),
    @TypeOrientation NVARCHAR(50),
    @Lieu NVARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LettreOrientation WHERE IdOrientation = @IdOrientation)
    BEGIN
        RAISERROR('Lettre orientation does not exist.', 16, 1);
        RETURN;
    END

    UPDATE LettreOrientation
    SET
        IdPatient = @IdPatient,
        Profession = @Profession,
        Antecedents = @Antecedents,
        Symptomes = @Symptomes,
        TypeOrientation = @TypeOrientation,
        Lieu = @Lieu
    WHERE IdOrientation = @IdOrientation;

    SELECT 'Lettre orientation updated successfully.' AS Message;
END;
GO

CREATE PROCEDURE DeleteLettreOrientation
    @IdOrientation INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LettreOrientation WHERE IdOrientation = @IdOrientation)
    BEGIN
        RAISERROR('Lettre orientation does not exist.', 16, 1);
        RETURN;
    END

    DELETE FROM LettreOrientation
    WHERE IdOrientation = @IdOrientation;

    SELECT 'Lettre orientation deleted successfully.' AS Message;
END;
GO

CREATE PROCEDURE GetLettreOrientationById
    @IdOrientation INT
AS
BEGIN
    SELECT IdOrientation, IdPatient, Profession, Antecedents, Symptomes, TypeOrientation, Lieu
    FROM LettreOrientation
    WHERE IdOrientation = @IdOrientation;
END;
GO

CREATE PROCEDURE ListAllLettresOrientation
AS
BEGIN
    SELECT IdOrientation, IdPatient, Profession, Antecedents, Symptomes, TypeOrientation, Lieu
    FROM LettreOrientation;
END;
GO