/*
C15513717
Lorcan Nolan
DT228/2
Group D
*/

/* Dropping tables in reverse oreder that they are created to respect 
foreign key constraints*/

DROP TABLE PackSize_Product CASCADE CONSTRAINTS PURGE;

DROP TABLE PackSize CASCADE CONSTRAINTS PURGE;

DROP TABLE NonDrugSale CASCADE CONSTRAINTS PURGE;

DROP TABLE Product CASCADE CONSTRAINTS PURGE;

DROP TABLE Supplier CASCADE CONSTRAINTS PURGE;

DROP TABLE Brand CASCADE CONSTRAINTS PURGE;

DROP TABLE PrescribedDrugs CASCADE CONSTRAINTS PURGE;

DROP TABLE DrugType CASCADE CONSTRAINTS PURGE;

DROP TABLE PrescriptionSale CASCADE CONSTRAINTS PURGE;

DROP TABLE Prescription CASCADE CONSTRAINTS PURGE;

DROP TABLE Staff CASCADE CONSTRAINTS PURGE;

DROP TABLE Customer CASCADE CONSTRAINTS PURGE;

DROP TABLE Doctor CASCADE CONSTRAINTS PURGE;

-- Name constraints in tables which were created when forward engineered from ERWin model

-- Create table Doctor and naming constraints as they were not named in ERWin model
CREATE TABLE Doctor
(
	doctorID             NUMBER(6) NOT NULL ,
	doctorName           VARCHAR2(30) NOT NULL ,
	surgeryName          VARCHAR2(30) NOT NULL ,
	surgeryAddress       VARCHAR2(50) NOT NULL ,
	CONSTRAINT doctor_pk PRIMARY KEY (doctorID)
);

/* Create table Doctor, naming and adding check constraints which were not 
created in the ERWin model */
CREATE TABLE Customer
(
	customerID           NUMBER(6) NOT NULL ,
	customerName         VARCHAR2(30) NOT NULL ,
	customerAddress      VARCHAR2(50) NOT NULL ,
	customerTelNum       NUMBER(10) NOT NULL ,
	customerEmail        VARCHAR2(50) DEFAULT 'unknown@unknown.com' ,
	medicalCardNum       NUMBER(10) ,
	CONSTRAINT customer_pk PRIMARY KEY (customerID) ,
  -- Ensures the @ symbol is included in entered email
	CONSTRAINT customeremail_chk CHECK (customerEmail like '%@%')
);

-- Create Staff table
CREATE TABLE Staff
(
	staffID              NUMBER(6) NOT NULL ,
	staffName            VARCHAR2(30) NOT NULL ,
	staffAddress         VARCHAR2(50) NOT NULL ,
	staffTelNum          NUMBER(10) NOT NULL ,
	staffEmail           VARCHAR2(50) DEFAULT 'unknown@unknown.com' ,
	staffPPS             VARCHAR2(9) NOT NULL ,
	staffRole            VARCHAR2(20) NOT NULL ,
	CONSTRAINT staff_pk PRIMARY KEY (staffID) ,
	CONSTRAINT staffemail_chk CHECK (staffEmail like '%@%')
);

/* Create Prescription table and naming foreign keys to Doctor, Customer
and staff tables. */
CREATE TABLE Prescription
(
	prescriptionID       NUMBER(6) NOT NULL ,
	customerID           NUMBER(6) NOT NULL ,
	doctorID             NUMBER(6) NOT NULL ,
	creatorStaffID       NUMBER(6) NOT NULL ,
	dispensorStaffID     NUMBER(6) NOT NULL ,
	collected			       CHAR NOT NULL ,
	CONSTRAINT prescription_pk PRIMARY KEY (prescriptionID),
	CONSTRAINT doc_pres_fk FOREIGN KEY (doctorID) REFERENCES Doctor (doctorID),
	CONSTRAINT cust_pres_fk FOREIGN KEY (customerID) REFERENCES Customer (customerID),
	CONSTRAINT creStaff_pres_fk FOREIGN KEY (creatorStaffID) REFERENCES Staff (staffID),
	CONSTRAINT disStaff_pres_fk FOREIGN KEY (dispensorStaffID) REFERENCES Staff (staffID),
	-- Ensures that only a Y or N can be inputted
	CONSTRAINT collected_chk CHECK (collected = 'Y' OR collected = 'N')
);

/* Create table PrescriptionSale which is identified by the primary key of 
prescription table. */
CREATE TABLE PrescriptionSale
(
	prescriptionID      NUMBER(6) NOT NULL ,
	presSaleDateTime	TIMESTAMP ,
	payType				VARCHAR2(20) ,
	CONSTRAINT pressale_pk PRIMARY KEY (prescriptionID) ,
  CONSTRAINT pres_pressale_fk FOREIGN KEY (prescriptionID) REFERENCES Prescription (prescriptionID) ,
	CONSTRAINT paytype_chk CHECK (payType = 'Cash' OR payType = 'Card' OR payType = 'Medical Card')
);

-- Create DrugType table
CREATE TABLE DrugType
(
	drugTypeName         VARCHAR2(20) NOT NULL ,
	normalDosage         VARCHAR2(10) NOT NULL ,
	prescriptionDrugOnly CHAR NOT NULL ,
	dispenseIns          VARCHAR2(50) NOT NULL ,
	useIns               VARCHAR2(50) NOT NULL ,
	CONSTRAINT drugtype_pk PRIMARY KEY (drugTypeName) ,
  -- Will only accept input of P or N
	CONSTRAINT presdrugonly_chk CHECK (prescriptionDrugOnly = 'P' OR prescriptionDrugOnly = 'N')
);

/* Create PrescribedDrugs table which is identified by a foreign key to the
Prescription table. Contains another foreign key to the DrugType table. */
CREATE TABLE PrescribedDrugs
(
	prescriptionID       NUMBER(6) NOT NULL ,
	drugTypeName         VARCHAR2(20) NOT NULL ,
	prescribedDosage     VARCHAR2(50) NOT NULL ,
	prescribedDuration   NUMBER(2) NOT NULL ,
	CONSTRAINT drugtype_presdrugs_fk FOREIGN KEY (drugTypeName) REFERENCES DrugType (drugTypeName),
	CONSTRAINT pres_presdrugs_fk FOREIGN KEY (prescriptionID) REFERENCES Prescription (prescriptionID)
);

-- Create Brand table
CREATE TABLE Brand
(
	brandID              NUMBER(6) NOT NULL ,
	brandName            VARCHAR2(20) NOT NULL ,
	CONSTRAINT brand_pk PRIMARY KEY (brandID)
);

-- Create Supplier table
CREATE TABLE Supplier
(
	supplierID           NUMBER(6) NOT NULL ,
	supplierName         VARCHAR2(30) NOT NULL ,
	supplierAddress      VARCHAR2(50) NOT NULL ,
	supplierTelNum       NUMBER(10) NOT NULL ,
	CONSTRAINT supplier_pk PRIMARY KEY (supplierID)
);

-- Create Product table
CREATE TABLE Product
(
	productID            NUMBER(6) NOT NULL ,
	drugOrNot            CHAR NOT NULL ,
	productDesc          VARCHAR2(30) NOT NULL ,
	productCost          NUMBER(5,2) NOT NULL ,
	productRetail        NUMBER(5,2) NOT NULL ,
	brandID              NUMBER(6) NOT NULL ,
	supplierID           NUMBER(6) NOT NULL ,
	drugTypeName         VARCHAR2(20) ,
	CONSTRAINT product_pk PRIMARY KEY (productID),
	CONSTRAINT brand_product_fk FOREIGN KEY (brandID) REFERENCES Brand (brandID),
	CONSTRAINT supplier_product_fk FOREIGN KEY (supplierID) REFERENCES Supplier (supplierID),
	CONSTRAINT drugtype_product_fk FOREIGN KEY (drugTypeName) REFERENCES DrugType (drugTypeName) ,
  -- Only accept inputs of Y or N
	CONSTRAINT drugornot_chk CHECK (drugOrNot = 'Y' OR drugOrNot = 'N')
);

/* Create NonDrugSale table which is identified by 2 foreign keys (staffID &
productID) and a TIMESTAMP date type.*/
CREATE TABLE NonDrugSale
(
	staffID              NUMBER(6) NOT NULL ,
	productID            NUMBER(6) NOT NULL ,
	saleDateTime         TIMESTAMP NOT NULL ,
	productQtySold       NUMBER(2) NOT NULL ,
	CONSTRAINT nondrugsale_pk PRIMARY KEY (staffID, productID, saleDateTime),
	CONSTRAINT staff_nondrugsale_fk FOREIGN KEY (staffID) REFERENCES Staff (staffID),
	CONSTRAINT product_nondrugsale_fk FOREIGN KEY (productID) REFERENCES Product (productID)
);

-- Create PackSize table
CREATE TABLE PackSize
(
	packSizeID           NUMBER(6) NOT NULL ,
	packSizeQty          NUMBER(3) NOT NULL ,
	CONSTRAINT packsize_pk PRIMARY KEY (packSizeID)
);

/* Create table PackSize_Product which is identified by the primary keys in
the product table and in the PackSize table. */
CREATE TABLE PackSize_Product
(
	packSizeID           NUMBER(6) NOT NULL ,
	productID            NUMBER(6) NOT NULL ,
	CONSTRAINT packsizeproduct_pk PRIMARY KEY (packSizeID,productID),
	CONSTRAINT packsize_packsizeproduct_fk FOREIGN KEY (packSizeID) REFERENCES PackSize (packSizeID),
	CONSTRAINT product_packsizeproduct_fk FOREIGN KEY (productID) REFERENCES Product (productID)
);

-- Populate tables enough to execute data manipulation section of assignment

INSERT INTO Doctor VALUES (1001, 'Patrick Watson', 'DeerPark Medical Centre', '2 Deerpark, Ashbourne, Co. Meath');
INSERT INTO Doctor VALUES (1002, 'Ursula Keane', 'Meadowbank Medical Centre', '1 Meadowbank Hill, Ratoath, Co. Meath');
INSERT INTO Doctor VALUES (1003, 'Bill Fegan', 'Finglas Medical', '45 Main Street Finglas, Dublin 11');
INSERT INTO Doctor VALUES (1004, 'John Veale', 'Temenos Medical Centre', 'Townyard Lane, Malahide, Dublin 17');

INSERT INTO Customer (customerID, customerName, customerAddress, customerTelNum, customerEmail)
VALUES (1001, 'Leonel Messi', '21 Tudor Grove, Ashbourne, Co. Meath', 0851010101, 'messi@gmail.com');
INSERT INTO Customer (customerID, customerName, customerAddress, customerTelNum, medicalCardNum)
VALUES (1002, 'Cristiano Ronaldo', '7 Fairview Road, Malahide, Dublin 17', 0857997799, 1230045600);
INSERT INTO Customer
VALUES (1003, 'Dale Doback', '6 Killegland, Ashbourne, Co. Meath', 0879870043, 'dragon@gmail.com', 4567891230);
INSERT INTO Customer (customerID, customerName, customerAddress, customerTelNum, customerEmail)
VALUES (1004, 'Brennan Huff', '36 Woodlands Park, Ratoath, Co. Meath', 0832223334, 'nighthawk@gmail.com');

INSERT INTO Staff
VALUES (1001, 'George Pharmacy', '12 Alderbrook Green, Ashbourne, Co. Meath', 0873311177, 'george@gmail.com', '7777886TP', 'Pharmacist');
INSERT INTO Staff
VALUES (1002, 'Kevin Redehan', '123 Dalkey Road, Dalkey, Dublin 24', 0859999999, 'shread@gmail.com', '9988811KR', 'Counter Staff');
INSERT INTO Staff (staffID, staffName, staffAddress, staffTelNum, staffPPS, staffRole)
VALUES (1003, 'Jesse Pinkman', '87, Navan Road, Cabra, Dublin 7', 0853555888, '1111228JP', 'Stock Clerk');
INSERT INTO Staff
VALUES (1004, 'Walter White', '18 Sycamore Road, Finglas, Dublin 11', 0870330131, 'heisenberg@gmail.com', '8882225WW', 'Pharmacist');

INSERT INTO Brand VALUES (1001, 'TGel');
INSERT INTO Brand VALUES (1002, 'Paralief');
INSERT INTO Brand VALUES (1003, 'Seven Seas');
INSERT INTO Brand VALUES (1004, 'Claritin');
INSERT INTO Brand VALUES (1005, 'Amoxil');
INSERT INTO Brand VALUES (1006, 'Fosamax');

INSERT INTO Supplier
VALUES (1001, 'Homer Simpson', '742 Evergreen Terrace', 0873692581);
INSERT INTO Supplier
VALUES (1002, 'John Goodman', '10 Cloverfield Lane', 0861244578);
INSERT INTO Supplier
VALUES (1003, 'Lebron James', '2 Cleveland Road, Cleveland', 0836458120);
INSERT INTO Supplier
VALUES (1004, 'Barack Obama', '1600 Pennsylvania Avenue, Washington', 0852542568);

INSERT INTO PackSize VALUES (1001, 12);
INSERT INTO PackSize VALUES (1002, 24);
INSERT INTO PackSize VALUES (1003, 48);
INSERT INTO PackSize VALUES (1004, 84);
INSERT INTO PackSize VALUES (1005, 128);

INSERT INTO DrugType
VALUES ('Paracetamol', '1000mg', 'N', 'Must be at least 16 to purchase.', 'Take no more than 1000mg every 4 hours.');
INSERT INTO DrugType 
VALUES ('Amoxicillin', '500mg', 'P', 'Do not sell to a customer without prescription.', 'Take tablet with food, do not chew.');
INSERT INTO DrugType 
VALUES ('Loratadine', '20mg', 'N', 'Suitable for adults and children over 6 years old.', 'Take one 20mg dosage daily.');
INSERT INTO DrugType 
VALUES ('Alendronic acid', '10mg', 'P', 'Not to be given to children and adolecsents.', 'Swallow with water, do not chew.');

INSERT INTO Product (productID, drugOrNot, productDesc, productCost, productRetail, brandID, supplierID)
VALUES (1001, 'N', 'Shampoo', 4.50, 5.99, 1001, 1002);
INSERT INTO Product (productID, drugOrNot, productDesc, productCost, productRetail, brandID, supplierID)
VALUES (1002, 'N', 'Vitamin and Mineral Supplement', 1.50, 3.99, 1003, 1001);
INSERT INTO Product 
VALUES (1003, 'Y', 'Painkiller', 2, 4.50, 1002, 1001, 'Paracetamol');
INSERT INTO Product 
VALUES (1004, 'Y', 'Antibiotic', 8.50, 11.99, 1005, 1004, 'Amoxicillin');
INSERT INTO Product 
VALUES (1005, 'Y', 'Antihistamine', 2.50, 4.99, 1004, 1003, 'Loratadine');
INSERT INTO Product 
VALUES (1006, 'Y', 'Bone strengthening drug', 7, 10.99, 1006, 1004, 'Alendronic acid');

INSERT INTO PackSize_Product VALUES (1002, 1003);
INSERT INTO PackSize_Product VALUES (1004, 1002);
INSERT INTO PackSize_Product VALUES (1002, 1005);
INSERT INTO PackSize_Product VALUES (1001, 1004);

INSERT INTO NonDrugSale
VALUES (1002, 1001, to_timestamp('05 Jul 2016 13:26','DD MON YYYY HH24:MI:SS'), 2);
INSERT INTO NonDrugSale
VALUES (1002, 1002, to_timestamp('05 Jul 2016 13:26','DD MON YYYY HH24:MI:SS'), 1);
INSERT INTO NonDrugSale
VALUES (1003, 1001, to_timestamp('21 Nov 2016 09:58','DD MON YYYY HH24:MI:SS'), 1);
INSERT INTO NonDrugSale
VALUES (1001, 1002, to_timestamp('02 Dec 2016 15:35','DD MON YYYY HH24:MI:SS'), 1);

INSERT INTO Prescription
VALUES (1001, 1003, 1001, 1002, 1001, 'N');
INSERT INTO Prescription
VALUES (1002, 1001, 1003, 1004, 1001, 'Y');
INSERT INTO Prescription
VALUES (1003, 1002, 1002, 1002, 1001, 'N');

INSERT INTO PrescribedDrugs
VALUES (1001, 'Amoxicillin', 'Take one 500mg twice daily.', 10);
INSERT INTO PrescribedDrugs
VALUES (1002, 'Alendronic acid', 'Take one 70mg tablet weekly', 70);
INSERT INTO PrescribedDrugs
VALUES (1003, 'Alendronic acid', 'Take one 70mg tablet weekly', 90);

INSERT INTO PrescriptionSale (prescriptionID)
VALUES (1001);
INSERT INTO PrescriptionSale
VALUES (1002, to_timestamp('01 Dec 2016 11:22','DD MON YYYY HH24:MI:SS'),'Cash');
INSERT INTO PrescriptionSale (prescriptionID)
VALUES (1003);

COMMIT;

/*  Inner Join #1 & Single Line Function #1
    - Label for bag when Leonel Messi collected his prescription */

SELECT UPPER(customerName), prescriptionID
FROM Prescription p
INNER JOIN Customer c 
ON p.customerID = c.customerID
WHERE customerName LIKE 'Leonel Messi';

/*  Inner Join #2 & Single Line Function #2
    - To find how long ago each TGel brand item was sold */
    
SELECT 'A TGel product was sold ' || ROUND( MONTHS_BETWEEN (SYSDATE, saleDateTime), 1)
|| ' months ago.' "When were TGel products sold"
FROM NonDrugSale n
INNER JOIN Product p
ON n.productID = p.productID
INNER JOIN Brand b
ON p.brandID = b.brandID
WHERE brandName LIKE 'TGel';

/*  Outer Join #1
    - Which products have a drug type name and which don't */
  
SELECT p.productDesc, d.drugTypeName
FROM Product p
LEFT OUTER JOIN DrugType d 
ON p.drugTypeName = d.drugTypeName;

/*  Outer Join #2
    - Which customers have a prescription */
    
SELECT customerName, prescriptionID
FROM Prescription p
RIGHT OUTER JOIN Customer c
ON p.customerID = c.customerID;

/*  UPDATE or DELETE selected data using a SUBQUERY.
    - Increase the retail price of all TGel products by 15% */
    
UPDATE Product 
SET productRetail = 1.15 * productRetail 
WHERE brandID IN ( 
SELECT brandID 
FROM Brand  
WHERE brandName LIKE 'TGel');

/*  ADD a column to a table.
    - Adding a column to Doctor table */
    
ALTER TABLE Doctor 
ADD doctorEmail VARCHAR2(50) DEFAULT 'unknown@unknown.com';

/* MODIFY a column to a table.
    - Modifying length of useIns column in DrugType table */
    
ALTER TABLE DrugType
MODIFY useIns VARCHAR2(75);

/*  Drop a column to a table.
    - Drop customerTelNum column in Customer table */
    
ALTER TABLE Customer
DROP COLUMN customerTelNum;

/*  Add a constraint to a column.
    - Ensure productRetail is higher than 50 cent */
    
ALTER TABLE Product
ADD CONSTRAINT productretail_chk CHECK (productRetail > .50);

/*  Drop a constraint from a column.
    - Drop customeremail_chk constraint from Customer Table */
    
ALTER TABLE Customer
DROP CONSTRAINT customeremail_chk;