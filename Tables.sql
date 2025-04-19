-- Table des Régions
CREATE TABLE Region (
    IdRegion INT IDENTITY(1,1) PRIMARY KEY,
    Nom NVARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE Stock (
    IdStock INT IDENTITY(1,1) PRIMARY KEY,
    IdMedicament INT NOT NULL,
    Quantite INT NOT NULL CHECK (Quantite >= 0),
	Famille VARCHAR(50),
	Reference VARCHAR(50),
    FOREIGN KEY (IdMedicament) REFERENCES Medicament(IdMedicament)
);

-- Table des Utilisateurs (intégration avec Active Directory)
CREATE TABLE Utilisateur (
    IdUtilisateur INT IDENTITY(1,1) PRIMARY KEY,
    ActiveDirectoryID NVARCHAR(255) UNIQUE NOT NULL,
    Username NVARCHAR(100) NOT NULL UNIQUE, 
    Password NVARCHAR(255) NOT NULL, 
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Administrateur', 'Médecin', 'Assistant')),
    IdRegion INT NOT NULL,
    DateCreation DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IdRegion) REFERENCES Region(IdRegion) ON DELETE CASCADE
);

CREATE TABLE Patient (
    IdPatient INT IDENTITY(1,1) PRIMARY KEY,
    IdRegion INT NOT NULL,
    Nom NVARCHAR(100) NOT NULL,
    Prenom NVARCHAR(100) NOT NULL,
    DateNaissance DATE NOT NULL,
    Sexe CHAR(1) NOT NULL CHECK (Sexe IN ('M', 'F')),
    Structure NVARCHAR(100) NOT NULL,
    Adresse NVARCHAR(255),
    Telephone NVARCHAR(20),
    Email NVARCHAR(255) UNIQUE,
    Poids INT,
    Taille INT,
    GroupeSanguin NVARCHAR(5),
    DateInscription DATETIME DEFAULT GETDATE(),
    Age AS DATEDIFF(YEAR, DateNaissance, GETDATE()) - 
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateNaissance, GETDATE()), DateNaissance) > GETDATE() 
            THEN 1 
            ELSE 0 
        END,
    FOREIGN KEY (IdRegion) REFERENCES Region(IdRegion) ON DELETE CASCADE
);

-- Table des Médecins
CREATE TABLE Medecin (
    IdMedecin INT PRIMARY KEY REFERENCES Utilisateur(IdUtilisateur) ON DELETE CASCADE,
    Nom NVARCHAR(100) NOT NULL,
    Prenom NVARCHAR(100) NOT NULL,
    Telephone NVARCHAR(20),
    Email NVARCHAR(255) UNIQUE
);

-- Table des Assistants
CREATE TABLE Assistant (
    IdAssistant INT PRIMARY KEY REFERENCES Utilisateur(IdUtilisateur) ON DELETE CASCADE,
    IdMedecin INT,
    Nom NVARCHAR(100) NOT NULL,
    Prenom NVARCHAR(100) NOT NULL,
    Telephone NVARCHAR(20),
    Email NVARCHAR(255) UNIQUE,
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin)
);

-- Table des Médicaments
CREATE TABLE Medicament (
    IdMedicament INT IDENTITY(1,1) PRIMARY KEY,
    NomMedicament NVARCHAR(255) NOT NULL UNIQUE,
    Description NVARCHAR(MAX),
    Dosage NVARCHAR(100),
    FormePharmaceutique NVARCHAR(100) CHECK (FormePharmaceutique IN ('Comprimé', 'Sirop', 'Injection', 'Gélule', 'Pommade', 'Autre')),
    StockDisponible INT NOT NULL CHECK (StockDisponible >= 0),
    DateAjout DATETIME DEFAULT GETDATE()
);

CREATE TABLE Stock (
    IdStock INT IDENTITY(1,1) PRIMARY KEY,
    IdMedicament INT NOT NULL,
    Quantite INT NOT NULL CHECK (Quantite >= 0),
	Famille VARCHAR(50),
	Reference VARCHAR(50),
    FOREIGN KEY (IdMedicament) REFERENCES Medicament(IdMedicament)
);

-- Table des Mouvements de Stock
CREATE TABLE StockMovement (
    IdMovement INT IDENTITY(1,1) PRIMARY KEY,
    IdStock INT NOT NULL,
    TypeMouvement NVARCHAR(50) NOT NULL CHECK (TypeMouvement IN ('Ajout', 'Sortie')),
    QuantiteMouvement INT NOT NULL CHECK (QuantiteMouvement > 0),
    DateMouvement DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IdStock) REFERENCES Stock(IdStock)
);

-- Table des Consultations
CREATE TABLE Consultation (
    IdConsultation INT IDENTITY(1,1) PRIMARY KEY,
    IdPatient INT NOT NULL,
    IdMedecin INT NOT NULL,
    DateConsultation DATETIME DEFAULT GETDATE(),
    Diagnostic NVARCHAR(MAX),
    Remarques NVARCHAR(MAX),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin)
);

-- Table de l'Historique des Consultations
CREATE TABLE HistoriqueConsultations (
    IdHistorique INT IDENTITY(1,1) PRIMARY KEY,
    IdConsultation INT NOT NULL,
    IdPatient INT NOT NULL,
    IdMedecin INT NOT NULL,
    DateConsultation DATETIME NOT NULL,
    Diagnostic NVARCHAR(MAX),
    Remarques NVARCHAR(MAX),
    FOREIGN KEY (IdConsultation) REFERENCES Consultation(IdConsultation),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin)
);

-- Table des Ordonnances
CREATE TABLE Ordonnance (
    IdOrdonnance INT IDENTITY(1,1) PRIMARY KEY,
    IdPatient INT NOT NULL,
    IdMedecin INT NOT NULL,
    DateOrdonnance DATETIME DEFAULT GETDATE(),
    Instructions NVARCHAR(MAX) NOT NULL,
    IdConsultation INT,
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin),
    FOREIGN KEY (IdConsultation) REFERENCES Consultation(IdConsultation)
);

-- Table des Visites Périodiques
CREATE TABLE VisitePeriodique (
    IdVisite INT IDENTITY(1,1) PRIMARY KEY,
    IdPatient INT NOT NULL,
    IdMedecin INT NOT NULL,
    DateHeureVisite DATETIME NOT NULL,
    TypeVisite NVARCHAR(50) CHECK (TypeVisite IN ('Annuel', 'Semestriel')) DEFAULT 'Annuel',
    Motif NVARCHAR(MAX) NOT NULL,
    Statut NVARCHAR(50) CHECK (Statut IN ('Programmé', 'Terminé', 'Annulé')) DEFAULT 'Programmé',
    Remarques NVARCHAR(MAX),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin)
);

-- Table des Maladies Chroniques
CREATE TABLE MaladieChronique (
    IdMaladie INT IDENTITY(1,1) PRIMARY KEY,
    NomMaladie NVARCHAR(255) NOT NULL UNIQUE,
    Description NVARCHAR(MAX)
);

-- Table des Dossiers Médicaux
CREATE TABLE DossierMedical (
    IdDossier INT IDENTITY(1,1) PRIMARY KEY,
    IdPatient INT NOT NULL,
    IdMaladie INT,
    DateCreation DATETIME DEFAULT GETDATE(),
    Allergies NVARCHAR(MAX),
    TraitementsActuels NVARCHAR(MAX),
    Remarques NVARCHAR(MAX),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdMaladie) REFERENCES MaladieChronique(IdMaladie)
);

-- Table des Cas Spéciaux
CREATE TABLE CasSpecial (
    IdCas INT IDENTITY(1,1) PRIMARY KEY,
    NomCas NVARCHAR(255) NOT NULL
);

-- Table des Détails d'Ordonnance
CREATE TABLE OrdonnanceMedicament (
    IdOrdonnanceMedicament INT IDENTITY(1,1) PRIMARY KEY,
    IdOrdonnance INT NOT NULL,
    IdMedicament INT NOT NULL,
    Description NVARCHAR(MAX),
    DureeTraitement INT NOT NULL,
    Frequence INT,
    FOREIGN KEY (IdOrdonnance) REFERENCES Ordonnance(IdOrdonnance),
    FOREIGN KEY (IdMedicament) REFERENCES Medicament(IdMedicament)
);

-- Table des Bilans Biologiques
CREATE TABLE BilanDetails (
    IdBilanDetails INT IDENTITY(1,1) PRIMARY KEY,
    FNS BIT,
    VS BIT,
    GlycemieJeun BIT,
    UreeSanguin BIT,
    CreatinineSanguine BIT,
    CholesterolTotal BIT,
    HDLChol BIT,
    LDLChol BIT,
    TG BIT,
    ASAT BIT,
    ALAT BIT,
    YGT BIT,
    PhosphataseAlcaline BIT,
    TSH BIT,
    FT3 BIT,
    FT4 BIT,
    FerSerique BIT,
    Microalbuminurie BIT,
    ECBU BIT,
    Fibrinogene BIT,
    CRP BIT,
    WallerRose BIT,
    Latex BIT,
    VitD3 BIT,
    HbA1C BIT,
    Calcemie BIT,
    Phosphoremie BIT,
    IonogrammeSanguin BIT,
    BilirubineIndirecte BIT,
    BilirubineTotale BIT,
    BilirubineDirecte BIT,
    Amylasemie BIT,
    AcideUrique BIT,
    PSATotaux BIT,
    PSALibres BIT,
    ChimieUrines BIT,
    Ferritinemie BIT
);

-- Table des Bilans Biologiques
CREATE TABLE BilanBiologique (
    IdBilan INT IDENTITY(1,1) PRIMARY KEY,
    IdBilanDetails INT NOT NULL,
    IdPatient INT NOT NULL,
    DateExamen DATE DEFAULT GETDATE(),
    VisaMedecin NVARCHAR(100),
    FOREIGN KEY (IdBilanDetails) REFERENCES BilanDetails(IdBilanDetails),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient)
);

-- Table des Certificats d'Arrêt de Travail
CREATE TABLE CertificatArretTravail (
    IdCertificat INT IDENTITY(1,1) PRIMARY KEY,
    IdMedecin INT NOT NULL,
    IdPatient INT NOT NULL,
    IdConsultation INT,
    JoursArret INT NOT NULL CHECK (JoursArret > 0),
    DateDebut DATE NOT NULL,
    ProlongationJours INT CHECK (ProlongationJours >= 0),
    DateProlongation DATE,
    DateCertificat DATE DEFAULT GETDATE(),
    DateFin DATE,
    Lieu NVARCHAR(100) DEFAULT 'ENAC',
    Motif NVARCHAR(255),
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient),
    FOREIGN KEY (IdConsultation) REFERENCES Consultation(IdConsultation)
);

-- Table des Certificats d'Aptitude
CREATE TABLE CertificatAptitude (
    IdCertificat INT IDENTITY(1,1) PRIMARY KEY,
    IdMedecin INT NOT NULL,
    IdPatient INT NOT NULL,
    TypeVisite NVARCHAR(50) CHECK (TypeVisite IN ('Visite périodique', 'Embauche', 'Visite')),
    PosteFonction NVARCHAR(100) NOT NULL,
    Aptitude NVARCHAR(50) CHECK (Aptitude IN ('Inaptitude définitive', 'Inaptitude temporaire', 'Aptitude avec aménagement', 'Aptitude')),
    JoursInaptitude INT CHECK (JoursInaptitude >= 0),
    DateCertificat DATE DEFAULT GETDATE(),
    Lieu NVARCHAR(100) DEFAULT 'ENAC',
    FOREIGN KEY (IdMedecin) REFERENCES Medecin(IdMedecin),
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient)
);

-- Table des Lettres d'Orientation
CREATE TABLE LettreOrientation (
    IdOrientation INT IDENTITY(1,1) PRIMARY KEY,
    IdPatient INT NOT NULL,
    Profession NVARCHAR(100) NOT NULL,
    Antecedents NVARCHAR(MAX),
    Symptomes NVARCHAR(MAX) NOT NULL,
    TypeOrientation NVARCHAR(50) CHECK (TypeOrientation IN ('Suivi Thérapeutique', 'Exploration', 'Avis')),
    DateOrientation DATE DEFAULT GETDATE(),
    Lieu NVARCHAR(100) DEFAULT 'Alger',
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient)
);


CREATE TABLE AptitudeReports (
    ReportID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patient(IdPatient),
    DoctorID INT FOREIGN KEY REFERENCES Medecin(IdMedecin),
    JobTitle NVARCHAR(255),
    MedicalCheckType NVARCHAR(50), -- 'Visite d’embauche' or 'Visite périodique'
    AptitudeStatus NVARCHAR(255),
    InaptitudeDays INT NULL,
    ReportDate DATETIME DEFAULT GETDATE(),
    Notes NVARCHAR(500) NULL
);
CREATE PROCEDURE InsertAptitudeReport
    @PatientID INT,
    @DoctorID INT,
    @JobTitle NVARCHAR(255),
    @MedicalCheckType NVARCHAR(50),
    @AptitudeStatus NVARCHAR(255),
    @InaptitudeDays INT = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AptitudeReports (PatientID, DoctorID, JobTitle, MedicalCheckType, AptitudeStatus, InaptitudeDays, ReportDate, Notes)
    VALUES (@PatientID, @DoctorID, @JobTitle, @MedicalCheckType, @AptitudeStatus, @InaptitudeDays, GETDATE(), @Notes);
END;

CREATE PROCEDURE GetAllAptitudeReports
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        MR.ReportID,
		P.Nom AS PatientName,
		P.Prenom AS PatientPrenom,
		P.Age,
		D.Nom AS DoctorName,
        D.Prenom AS DoctorPrenom,
        MR.JobTitle,
        MR.MedicalCheckType,
        MR.AptitudeStatus,
        MR.InaptitudeDays,
        MR.ReportDate,
        MR.Notes
    FROM AptitudeReports MR
    INNER JOIN Patient P ON MR.PatientID = P.IdPatient
	INNER JOIN Medecin D ON MR.DoctorID = D.IdMedecin
    ORDER BY MR.ReportDate DESC;
END;



-- ✅ Corrected Table Structure
CREATE TABLE LettreOrientationReport (
    IdOrientation INT IDENTITY(1,1) PRIMARY KEY,  
    IdPatient INT NOT NULL,
    Profession NVARCHAR(100) NOT NULL,  -- Increased size for flexibility
    Antecedents NVARCHAR(MAX),  
    Symptomes NVARCHAR(MAX) NOT NULL,  
    TypeOrientation NVARCHAR(50) NOT NULL CHECK (TypeOrientation IN ('Suivi Thérapeutique', 'Exploration', 'Avis')),  
    DateOrientation DATE DEFAULT GETDATE(),  
    Lieu NVARCHAR(100) DEFAULT 'Alger',  
    FOREIGN KEY (IdPatient) REFERENCES Patient(IdPatient) ON DELETE CASCADE 
);

-- ✅ Corrected Stored Procedure
CREATE PROCEDURE GetOrientationLetterReport
    @IdPatient INT 
AS 
BEGIN 
    SET NOCOUNT ON; 

    SELECT  
        L.IdOrientation,
        P.IdPatient, 
        P.Nom + ' ' + P.Prenom AS PatientName, 
        P.Age, 
        L.Profession,  -- ✅ Now correctly from LettreOrientationReport
        P.GroupeSanguin, 
        P.Adresse, 
        P.Telephone, 
        P.Email, 
        L.Antecedents, 
        L.Symptomes, 
        L.TypeOrientation, 
        L.DateOrientation, 
        L.Lieu, 
        CONVERT(NVARCHAR, L.DateOrientation, 103) AS ReportDate 
    FROM Patient P 
    INNER JOIN LettreOrientationReport L ON P.IdPatient = L.IdPatient  -- ✅ Corrected table reference
	WHERE P.IdPatient = @IdPatient;
END;


CREATE PROCEDURE GetAllCertificats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.IdCertificat, 
        c.DateCertificat, 
        c.DateDebut, 
        c.JoursArret, 
        c.ProlongationJours, 
        c.DateProlongation, 
        c.Lieu, 
        c.Motif,
        m.IdMedecin, 
        m.Nom AS NomMedecin, 
        m.Prenom AS PrenomMedecin,
        p.IdPatient, 
        p.Nom AS NomPatient, 
        p.Prenom AS PrenomPatient
    FROM CertificatArretTravail c
    JOIN Medecin m ON c.IdMedecin = m.IdMedecin
    JOIN Patient p ON c.IdPatient = p.IdPatient
    ORDER BY c.DateCertificat DESC;
END;




