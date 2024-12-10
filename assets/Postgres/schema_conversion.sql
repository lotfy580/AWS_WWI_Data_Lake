--Description: This is Schema conversion Script from SQL-Server to Postgres for WideWorldImporters Database.
--             the Script does not include forign keys, check constraints or triggers to apply full migration 

--Author: Lotfy Ashmawy




-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS application;

CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE SCHEMA IF NOT EXISTS integration;

CREATE SCHEMA IF NOT EXISTS purchasing;

CREATE SCHEMA IF NOT EXISTS sales;

CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE SCHEMA IF NOT EXISTS website;

-- ------------ Write CREATE-SEQUENCE-stage scripts -----------

CREATE SEQUENCE IF NOT EXISTS sequences.buyinggroupid AS bigint
INCREMENT BY 1
START WITH 3
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.cityid AS bigint
INCREMENT BY 1
START WITH 38187
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.colorid AS bigint
INCREMENT BY 1
START WITH 37
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.countryid AS bigint
INCREMENT BY 1
START WITH 242
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.customercategoryid AS bigint
INCREMENT BY 1
START WITH 9
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.customerid AS bigint
INCREMENT BY 1
START WITH 1062
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.deliverymethodid AS bigint
INCREMENT BY 1
START WITH 11
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.invoiceid AS bigint
INCREMENT BY 1
START WITH 70511
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.invoicelineid AS bigint
INCREMENT BY 1
START WITH 228266
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.orderid AS bigint
INCREMENT BY 1
START WITH 73596
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.orderlineid AS bigint
INCREMENT BY 1
START WITH 231413
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.packagetypeid AS bigint
INCREMENT BY 1
START WITH 15
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.paymentmethodid AS bigint
INCREMENT BY 1
START WITH 5
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.personid AS bigint
INCREMENT BY 1
START WITH 3262
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.purchaseorderid AS bigint
INCREMENT BY 1
START WITH 2075
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.purchaseorderlineid AS bigint
INCREMENT BY 1
START WITH 8368
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.specialdealid AS bigint
INCREMENT BY 1
START WITH 3
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.stateprovinceid AS bigint
INCREMENT BY 1
START WITH 54
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.stockgroupid AS bigint
INCREMENT BY 1
START WITH 11
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.stockitemid AS bigint
INCREMENT BY 1
START WITH 228
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.stockitemstockgroupid AS bigint
INCREMENT BY 1
START WITH 443
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.suppliercategoryid AS bigint
INCREMENT BY 1
START WITH 10
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.supplierid AS bigint
INCREMENT BY 1
START WITH 14
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.systemparameterid AS bigint
INCREMENT BY 1
START WITH 2
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.transactionid AS bigint
INCREMENT BY 1
START WITH 336253
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

CREATE SEQUENCE IF NOT EXISTS sequences.transactiontypeid AS bigint
INCREMENT BY 1
START WITH 14
MAXVALUE 2147483647
MINVALUE -2147483648
NO CYCLE;

-- ------------ Write CREATE-TYPE-stage scripts -----------

CREATE TYPE website.orderidlist$aws$t AS (
orderid INTEGER
);

CREATE TYPE website.orderlinelist$aws$t AS (
orderreference INTEGER,
stockitemid INTEGER,
description VARCHAR(100),
quantity INTEGER
);

CREATE TYPE website.orderlist$aws$t AS (
orderreference INTEGER,
customerid INTEGER,
contactpersonid INTEGER,
expecteddeliverydate DATE,
customerpurchaseordernumber VARCHAR(20),
isundersupplybackordered NUMERIC(1,0),
comments TEXT,
deliveryinstructions TEXT
);

CREATE TYPE website.sensordatalist$aws$t AS (
sensordatalistid INTEGER,
coldroomsensornumber INTEGER,
recordedwhen TIMESTAMP(6) WITHOUT TIME ZONE,
temperature NUMERIC(18,2)
);

-- ------------ Write CREATE-DOMAIN-stage scripts -----------

CREATE DOMAIN website.orderidlist AS website.orderidlist$aws$t [];

CREATE DOMAIN website.orderlinelist AS website.orderlinelist$aws$t [];

CREATE DOMAIN website.orderlist AS website.orderlist$aws$t [];

CREATE DOMAIN website.sensordatalist AS website.sensordatalist$aws$t [];

-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE application.cities(
    cityid INTEGER NOT NULL DEFAULT nextval('sequences.cityid'),
    cityname VARCHAR(50) NOT NULL,
    stateprovinceid INTEGER NOT NULL,
    location VARCHAR,
    latestrecordedpopulation BIGINT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.cities_archive(
    cityid INTEGER NOT NULL,
    cityname VARCHAR(50) NOT NULL,
    stateprovinceid INTEGER NOT NULL,
    location VARCHAR,
    latestrecordedpopulation BIGINT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.countries(
    countryid INTEGER NOT NULL DEFAULT nextval('sequences.countryid'),
    countryname VARCHAR(60) NOT NULL,
    formalname VARCHAR(60) NOT NULL,
    isoalpha3code VARCHAR(3),
    isonumericcode INTEGER,
    countrytype VARCHAR(20),
    latestrecordedpopulation BIGINT,
    continent VARCHAR(30) NOT NULL,
    region VARCHAR(30) NOT NULL,
    subregion VARCHAR(30) NOT NULL,
    border VARCHAR,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.countries_archive(
    countryid INTEGER NOT NULL,
    countryname VARCHAR(60) NOT NULL,
    formalname VARCHAR(60) NOT NULL,
    isoalpha3code VARCHAR(3),
    isonumericcode INTEGER,
    countrytype VARCHAR(20),
    latestrecordedpopulation BIGINT,
    continent VARCHAR(30) NOT NULL,
    region VARCHAR(30) NOT NULL,
    subregion VARCHAR(30) NOT NULL,
    border VARCHAR,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.deliverymethods(
    deliverymethodid INTEGER NOT NULL DEFAULT nextval('sequences.deliverymethodid'),
    deliverymethodname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.deliverymethods_archive(
    deliverymethodid INTEGER NOT NULL,
    deliverymethodname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.paymentmethods(
    paymentmethodid INTEGER NOT NULL DEFAULT nextval('sequences.paymentmethodid'),
    paymentmethodname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.paymentmethods_archive(
    paymentmethodid INTEGER NOT NULL,
    paymentmethodname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.people(
    personid INTEGER NOT NULL DEFAULT nextval('sequences.personid'),
    fullname VARCHAR(50) NOT NULL,
    preferredname VARCHAR(50) NOT NULL,
    searchname VARCHAR(101) NOT NULL,
    ispermittedtologon NUMERIC(1,0) NOT NULL,
    logonname VARCHAR(50),
    isexternallogonprovider NUMERIC(1,0) NOT NULL,
    hashedpassword BYTEA,
    issystemuser NUMERIC(1,0) NOT NULL,
    isemployee NUMERIC(1,0) NOT NULL,
    issalesperson NUMERIC(1,0) NOT NULL,
    userpreferences TEXT,
    phonenumber VARCHAR(20),
    faxnumber VARCHAR(20),
    emailaddress VARCHAR(256),
    photo BYTEA,
    customfields TEXT,
    otherlanguages TEXT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.people_archive(
    personid INTEGER NOT NULL,
    fullname VARCHAR(50) NOT NULL,
    preferredname VARCHAR(50) NOT NULL,
    searchname VARCHAR(101) NOT NULL,
    ispermittedtologon NUMERIC(1,0) NOT NULL,
    logonname VARCHAR(50),
    isexternallogonprovider NUMERIC(1,0) NOT NULL,
    hashedpassword BYTEA,
    issystemuser NUMERIC(1,0) NOT NULL,
    isemployee NUMERIC(1,0) NOT NULL,
    issalesperson NUMERIC(1,0) NOT NULL,
    userpreferences TEXT,
    phonenumber VARCHAR(20),
    faxnumber VARCHAR(20),
    emailaddress VARCHAR(256),
    photo BYTEA,
    customfields TEXT,
    otherlanguages TEXT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.stateprovinces(
    stateprovinceid INTEGER NOT NULL DEFAULT nextval('sequences.stateprovinceid'),
    stateprovincecode VARCHAR(5) NOT NULL,
    stateprovincename VARCHAR(50) NOT NULL,
    countryid INTEGER NOT NULL,
    salesterritory VARCHAR(50) NOT NULL,
    border VARCHAR,
    latestrecordedpopulation BIGINT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.stateprovinces_archive(
    stateprovinceid INTEGER NOT NULL,
    stateprovincecode VARCHAR(5) NOT NULL,
    stateprovincename VARCHAR(50) NOT NULL,
    countryid INTEGER NOT NULL,
    salesterritory VARCHAR(50) NOT NULL,
    border VARCHAR,
    latestrecordedpopulation BIGINT,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.systemparameters(
    systemparameterid INTEGER NOT NULL DEFAULT nextval('sequences.systemparameterid'),
    deliveryaddressline1 VARCHAR(60) NOT NULL,
    deliveryaddressline2 VARCHAR(60),
    deliverycityid INTEGER NOT NULL,
    deliverypostalcode VARCHAR(10) NOT NULL,
    deliverylocation VARCHAR NOT NULL,
    postaladdressline1 VARCHAR(60) NOT NULL,
    postaladdressline2 VARCHAR(60),
    postalcityid INTEGER NOT NULL,
    postalpostalcode VARCHAR(10) NOT NULL,
    applicationsettings TEXT NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.transactiontypes(
    transactiontypeid INTEGER NOT NULL DEFAULT nextval('sequences.transactiontypeid'),
    transactiontypename VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE application.transactiontypes_archive(
    transactiontypeid INTEGER NOT NULL,
    transactiontypename VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.purchaseorderlines(
    purchaseorderlineid INTEGER NOT NULL DEFAULT nextval('sequences.purchaseorderlineid'),
    purchaseorderid INTEGER NOT NULL,
    stockitemid INTEGER NOT NULL,
    orderedouters INTEGER NOT NULL,
    description VARCHAR(100) NOT NULL,
    receivedouters INTEGER NOT NULL,
    packagetypeid INTEGER NOT NULL,
    expectedunitpriceperouter NUMERIC(18,2),
    lastreceiptdate DATE,
    isorderlinefinalized NUMERIC(1,0) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.purchaseorders(
    purchaseorderid INTEGER NOT NULL DEFAULT nextval('sequences.purchaseorderid'),
    supplierid INTEGER NOT NULL,
    orderdate DATE NOT NULL,
    deliverymethodid INTEGER NOT NULL,
    contactpersonid INTEGER NOT NULL,
    expecteddeliverydate DATE,
    supplierreference VARCHAR(20),
    isorderfinalized NUMERIC(1,0) NOT NULL,
    comments TEXT,
    internalcomments TEXT,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.suppliercategories(
    suppliercategoryid INTEGER NOT NULL DEFAULT nextval('sequences.suppliercategoryid'),
    suppliercategoryname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.suppliercategories_archive(
    suppliercategoryid INTEGER NOT NULL,
    suppliercategoryname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.suppliers(
    supplierid INTEGER NOT NULL DEFAULT nextval('sequences.supplierid'),
    suppliername VARCHAR(100) NOT NULL,
    suppliercategoryid INTEGER NOT NULL,
    primarycontactpersonid INTEGER NOT NULL,
    alternatecontactpersonid INTEGER NOT NULL,
    deliverymethodid INTEGER,
    deliverycityid INTEGER NOT NULL,
    postalcityid INTEGER NOT NULL,
    supplierreference VARCHAR(20),
    bankaccountname VARCHAR(50),
    bankaccountbranch VARCHAR(50),
    bankaccountcode VARCHAR(20),
    bankaccountnumber VARCHAR(20),
    bankinternationalcode VARCHAR(20),
    paymentdays INTEGER NOT NULL,
    internalcomments TEXT,
    phonenumber VARCHAR(20) NOT NULL,
    faxnumber VARCHAR(20) NOT NULL,
    websiteurl VARCHAR(256) NOT NULL,
    deliveryaddressline1 VARCHAR(60) NOT NULL,
    deliveryaddressline2 VARCHAR(60),
    deliverypostalcode VARCHAR(10) NOT NULL,
    deliverylocation VARCHAR,
    postaladdressline1 VARCHAR(60) NOT NULL,
    postaladdressline2 VARCHAR(60),
    postalpostalcode VARCHAR(10) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.suppliers_archive(
    supplierid INTEGER NOT NULL,
    suppliername VARCHAR(100) NOT NULL,
    suppliercategoryid INTEGER NOT NULL,
    primarycontactpersonid INTEGER NOT NULL,
    alternatecontactpersonid INTEGER NOT NULL,
    deliverymethodid INTEGER,
    deliverycityid INTEGER NOT NULL,
    postalcityid INTEGER NOT NULL,
    supplierreference VARCHAR(20),
    bankaccountname VARCHAR(50),
    bankaccountbranch VARCHAR(50),
    bankaccountcode VARCHAR(20),
    bankaccountnumber VARCHAR(20),
    bankinternationalcode VARCHAR(20),
    paymentdays INTEGER NOT NULL,
    internalcomments TEXT,
    phonenumber VARCHAR(20) NOT NULL,
    faxnumber VARCHAR(20) NOT NULL,
    websiteurl VARCHAR(256) NOT NULL,
    deliveryaddressline1 VARCHAR(60) NOT NULL,
    deliveryaddressline2 VARCHAR(60),
    deliverypostalcode VARCHAR(10) NOT NULL,
    deliverylocation VARCHAR,
    postaladdressline1 VARCHAR(60) NOT NULL,
    postaladdressline2 VARCHAR(60),
    postalpostalcode VARCHAR(10) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE purchasing.suppliertransactions(
    suppliertransactionid INTEGER NOT NULL DEFAULT nextval('sequences.transactionid'),
    supplierid INTEGER NOT NULL,
    transactiontypeid INTEGER NOT NULL,
    purchaseorderid INTEGER,
    paymentmethodid INTEGER,
    supplierinvoicenumber VARCHAR(20),
    transactiondate DATE NOT NULL,
    amountexcludingtax NUMERIC(18,2) NOT NULL,
    taxamount NUMERIC(18,2) NOT NULL,
    transactionamount NUMERIC(18,2) NOT NULL,
    outstandingbalance NUMERIC(18,2) NOT NULL,
    finalizationdate DATE,
    isfinalized NUMERIC(1,0),
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)    
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.buyinggroups(
    buyinggroupid INTEGER NOT NULL DEFAULT nextval('sequences.buyinggroupid'),
    buyinggroupname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.buyinggroups_archive(
    buyinggroupid INTEGER NOT NULL,
    buyinggroupname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.customercategories(
    customercategoryid INTEGER NOT NULL DEFAULT nextval('sequences.customercategoryid'),
    customercategoryname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.customercategories_archive(
    customercategoryid INTEGER NOT NULL,
    customercategoryname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.customers(
    customerid INTEGER NOT NULL DEFAULT nextval('sequences.customerid'),
    customername VARCHAR(100) NOT NULL,
    billtocustomerid INTEGER NOT NULL,
    customercategoryid INTEGER NOT NULL,
    buyinggroupid INTEGER,
    primarycontactpersonid INTEGER NOT NULL,
    alternatecontactpersonid INTEGER,
    deliverymethodid INTEGER NOT NULL,
    deliverycityid INTEGER NOT NULL,
    postalcityid INTEGER NOT NULL,
    creditlimit NUMERIC(18,2),
    accountopeneddate DATE NOT NULL,
    standarddiscountpercentage NUMERIC(18,3) NOT NULL,
    isstatementsent NUMERIC(1,0) NOT NULL,
    isoncredithold NUMERIC(1,0) NOT NULL,
    paymentdays INTEGER NOT NULL,
    phonenumber VARCHAR(20) NOT NULL,
    faxnumber VARCHAR(20) NOT NULL,
    deliveryrun VARCHAR(5),
    runposition VARCHAR(5),
    websiteurl VARCHAR(256) NOT NULL,
    deliveryaddressline1 VARCHAR(60) NOT NULL,
    deliveryaddressline2 VARCHAR(60),
    deliverypostalcode VARCHAR(10) NOT NULL,
    deliverylocation VARCHAR,
    postaladdressline1 VARCHAR(60) NOT NULL,
    postaladdressline2 VARCHAR(60),
    postalpostalcode VARCHAR(10) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.customers_archive(
    customerid INTEGER NOT NULL,
    customername VARCHAR(100) NOT NULL,
    billtocustomerid INTEGER NOT NULL,
    customercategoryid INTEGER NOT NULL,
    buyinggroupid INTEGER,
    primarycontactpersonid INTEGER NOT NULL,
    alternatecontactpersonid INTEGER,
    deliverymethodid INTEGER NOT NULL,
    deliverycityid INTEGER NOT NULL,
    postalcityid INTEGER NOT NULL,
    creditlimit NUMERIC(18,2),
    accountopeneddate DATE NOT NULL,
    standarddiscountpercentage NUMERIC(18,3) NOT NULL,
    isstatementsent NUMERIC(1,0) NOT NULL,
    isoncredithold NUMERIC(1,0) NOT NULL,
    paymentdays INTEGER NOT NULL,
    phonenumber VARCHAR(20) NOT NULL,
    faxnumber VARCHAR(20) NOT NULL,
    deliveryrun VARCHAR(5),
    runposition VARCHAR(5),
    websiteurl VARCHAR(256) NOT NULL,
    deliveryaddressline1 VARCHAR(60) NOT NULL,
    deliveryaddressline2 VARCHAR(60),
    deliverypostalcode VARCHAR(10) NOT NULL,
    deliverylocation VARCHAR,
    postaladdressline1 VARCHAR(60) NOT NULL,
    postaladdressline2 VARCHAR(60),
    postalpostalcode VARCHAR(10) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.customertransactions(
    customertransactionid INTEGER NOT NULL DEFAULT nextval('sequences.transactionid'),
    customerid INTEGER NOT NULL,
    transactiontypeid INTEGER NOT NULL,
    invoiceid INTEGER,
    paymentmethodid INTEGER,
    transactiondate DATE NOT NULL,
    amountexcludingtax NUMERIC(18,2) NOT NULL,
    taxamount NUMERIC(18,2) NOT NULL,
    transactionamount NUMERIC(18,2) NOT NULL,
    outstandingbalance NUMERIC(18,2) NOT NULL,
    finalizationdate DATE,
    isfinalized NUMERIC(1,0),
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.invoicelines(
    invoicelineid INTEGER NOT NULL DEFAULT nextval('sequences.invoicelineid'),
    invoiceid INTEGER NOT NULL,
    stockitemid INTEGER NOT NULL,
    description VARCHAR(100) NOT NULL,
    packagetypeid INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unitprice NUMERIC(18,2),
    taxrate NUMERIC(18,3) NOT NULL,
    taxamount NUMERIC(18,2) NOT NULL,
    lineprofit NUMERIC(18,2) NOT NULL,
    extendedprice NUMERIC(18,2) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.invoices(
    invoiceid INTEGER NOT NULL DEFAULT nextval('sequences.invoiceid'),
    customerid INTEGER NOT NULL,
    billtocustomerid INTEGER NOT NULL,
    orderid INTEGER,
    deliverymethodid INTEGER NOT NULL,
    contactpersonid INTEGER NOT NULL,
    accountspersonid INTEGER NOT NULL,
    salespersonpersonid INTEGER NOT NULL,
    packedbypersonid INTEGER NOT NULL,
    invoicedate DATE NOT NULL,
    customerpurchaseordernumber VARCHAR(20),
    iscreditnote NUMERIC(1,0) NOT NULL,
    creditnotereason TEXT,
    comments TEXT,
    deliveryinstructions TEXT,
    internalcomments TEXT,
    totaldryitems INTEGER NOT NULL,
    totalchilleritems INTEGER NOT NULL,
    deliveryrun VARCHAR(5),
    runposition VARCHAR(5),
    returneddeliverydata TEXT,
    confirmeddeliverytime TIMESTAMP(6) WITHOUT TIME ZONE,
    confirmedreceivedby VARCHAR(4000),
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.orderlines(
    orderlineid INTEGER NOT NULL DEFAULT nextval('sequences.orderlineid'),
    orderid INTEGER NOT NULL,
    stockitemid INTEGER NOT NULL,
    description VARCHAR(100) NOT NULL,
    packagetypeid INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unitprice NUMERIC(18,2),
    taxrate NUMERIC(18,3) NOT NULL,
    pickedquantity INTEGER NOT NULL,
    pickingcompletedwhen TIMESTAMP(6) WITHOUT TIME ZONE,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.orders(
    orderid INTEGER NOT NULL DEFAULT nextval('sequences.orderid'),
    customerid INTEGER NOT NULL,
    salespersonpersonid INTEGER NOT NULL,
    pickedbypersonid INTEGER,
    contactpersonid INTEGER NOT NULL,
    backorderorderid INTEGER,
    orderdate DATE NOT NULL,
    expecteddeliverydate DATE NOT NULL,
    customerpurchaseordernumber VARCHAR(20),
    isundersupplybackordered NUMERIC(1,0) NOT NULL,
    comments TEXT,
    deliveryinstructions TEXT,
    internalcomments TEXT,
    pickingcompletedwhen TIMESTAMP(6) WITHOUT TIME ZONE,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE sales.specialdeals(
    specialdealid INTEGER NOT NULL DEFAULT nextval('sequences.specialdealid'),
    stockitemid INTEGER,
    customerid INTEGER,
    buyinggroupid INTEGER,
    customercategoryid INTEGER,
    stockgroupid INTEGER,
    dealdescription VARCHAR(30) NOT NULL,
    startdate DATE NOT NULL,
    enddate DATE NOT NULL,
    discountamount NUMERIC(18,2),
    discountpercentage NUMERIC(18,3),
    unitprice NUMERIC(18,2),
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.coldroomtemperatures(
    coldroomtemperatureid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    coldroomsensornumber INTEGER NOT NULL,
    recordedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    temperature NUMERIC(10,2) NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.coldroomtemperatures_archive(
    coldroomtemperatureid BIGINT NOT NULL,
    coldroomsensornumber INTEGER NOT NULL,
    recordedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    temperature NUMERIC(10,2) NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.colors(
    colorid INTEGER NOT NULL DEFAULT nextval('sequences.colorid'),
    colorname VARCHAR(20) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.colors_archive(
    colorid INTEGER NOT NULL,
    colorname VARCHAR(20) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.packagetypes(
    packagetypeid INTEGER NOT NULL DEFAULT nextval('sequences.packagetypeid'),
    packagetypename VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.packagetypes_archive(
    packagetypeid INTEGER NOT NULL,
    packagetypename VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockgroups(
    stockgroupid INTEGER NOT NULL DEFAULT nextval('sequences.stockgroupid'),
    stockgroupname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockgroups_archive(
    stockgroupid INTEGER NOT NULL,
    stockgroupname VARCHAR(50) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockitemholdings(
    stockitemid INTEGER NOT NULL,
    quantityonhand INTEGER NOT NULL,
    binlocation VARCHAR(20) NOT NULL,
    laststocktakequantity INTEGER NOT NULL,
    lastcostprice NUMERIC(18,2) NOT NULL,
    reorderlevel INTEGER NOT NULL,
    targetstocklevel INTEGER NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockitems(
    stockitemid INTEGER NOT NULL DEFAULT nextval('sequences.stockitemid'),
    stockitemname VARCHAR(100) NOT NULL,
    supplierid INTEGER NOT NULL,
    colorid INTEGER,
    unitpackageid INTEGER NOT NULL,
    outerpackageid INTEGER NOT NULL,
    brand VARCHAR(50),
    size VARCHAR(20),
    leadtimedays INTEGER NOT NULL,
    quantityperouter INTEGER NOT NULL,
    ischillerstock NUMERIC(1,0) NOT NULL,
    barcode VARCHAR(50),
    taxrate NUMERIC(18,3) NOT NULL,
    unitprice NUMERIC(18,2) NOT NULL,
    recommendedretailprice NUMERIC(18,2),
    typicalweightperunit NUMERIC(18,3) NOT NULL,
    marketingcomments TEXT,
    internalcomments TEXT,
    photo BYTEA,
    customfields TEXT,
    tags TEXT,
    searchdetails TEXT NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockitems_archive(
    stockitemid INTEGER NOT NULL,
    stockitemname VARCHAR(100) NOT NULL,
    supplierid INTEGER NOT NULL,
    colorid INTEGER,
    unitpackageid INTEGER NOT NULL,
    outerpackageid INTEGER NOT NULL,
    brand VARCHAR(50),
    size VARCHAR(20),
    leadtimedays INTEGER NOT NULL,
    quantityperouter INTEGER NOT NULL,
    ischillerstock NUMERIC(1,0) NOT NULL,
    barcode VARCHAR(50),
    taxrate NUMERIC(18,3) NOT NULL,
    unitprice NUMERIC(18,2) NOT NULL,
    recommendedretailprice NUMERIC(18,2),
    typicalweightperunit NUMERIC(18,3) NOT NULL,
    marketingcomments TEXT,
    internalcomments TEXT,
    photo BYTEA,
    customfields TEXT,
    tags TEXT,
    searchdetails TEXT NOT NULL,
    lasteditedby INTEGER NOT NULL,
    validfrom TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    validto TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockitemstockgroups(
    stockitemstockgroupid INTEGER NOT NULL DEFAULT nextval('sequences.stockitemstockgroupid'),
    stockitemid INTEGER NOT NULL,
    stockgroupid INTEGER NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.stockitemtransactions(
    stockitemtransactionid INTEGER NOT NULL DEFAULT nextval('sequences.transactionid'),
    stockitemid INTEGER NOT NULL,
    transactiontypeid INTEGER NOT NULL,
    customerid INTEGER,
    invoiceid INTEGER,
    supplierid INTEGER,
    purchaseorderid INTEGER,
    transactionoccurredwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    quantity NUMERIC(18,3) NOT NULL,
    lasteditedby INTEGER NOT NULL,
    lasteditedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL DEFAULT clock_timestamp()
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE warehouse.vehicletemperatures(
    vehicletemperatureid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    vehicleregistration VARCHAR(20) NOT NULL,
    chillersensornumber INTEGER NOT NULL,
    recordedwhen TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    temperature NUMERIC(10,2) NOT NULL,
    fullsensordata VARCHAR(1000),
    iscompressed NUMERIC(1,0) NOT NULL,
    compressedsensordata BYTEA
)
        WITH (
        OIDS=FALSE
        );

-- ------------ Write CREATE-VIEW-stage scripts -----------

CREATE OR REPLACE  VIEW website.customers (customerid, customername, customercategoryname, primarycontact, alternatecontact, phonenumber, faxnumber, buyinggroupname, websiteurl, deliverymethod, cityname, deliverylocation, deliveryrun, runposition) AS
SELECT
    s.customerid, s.customername, sc.customercategoryname, pp.fullname AS primarycontact, ap.fullname AS alternatecontact, s.phonenumber, s.faxnumber, bg.buyinggroupname, s.websiteurl, dm.deliverymethodname AS deliverymethod, c.cityname AS cityname, s.deliverylocation AS deliverylocation, s.deliveryrun, s.runposition
    FROM sales.customers AS s
    LEFT OUTER JOIN sales.customercategories AS sc
        ON s.customercategoryid = sc.customercategoryid
    LEFT OUTER JOIN application.people AS pp
        ON s.primarycontactpersonid = pp.personid
    LEFT OUTER JOIN application.people AS ap
        ON s.alternatecontactpersonid = ap.personid
    LEFT OUTER JOIN sales.buyinggroups AS bg
        ON s.buyinggroupid = bg.buyinggroupid
    LEFT OUTER JOIN application.deliverymethods AS dm
        ON s.deliverymethodid = dm.deliverymethodid
    LEFT OUTER JOIN application.cities AS c
        ON s.deliverycityid = c.cityid;

CREATE OR REPLACE  VIEW website.suppliers (supplierid, suppliername, suppliercategoryname, primarycontact, alternatecontact, phonenumber, faxnumber, websiteurl, deliverymethod, cityname, deliverylocation, supplierreference) AS
SELECT
    s.supplierid, s.suppliername, sc.suppliercategoryname, pp.fullname AS primarycontact, ap.fullname AS alternatecontact, s.phonenumber, s.faxnumber, s.websiteurl, dm.deliverymethodname AS deliverymethod, c.cityname AS cityname, s.deliverylocation AS deliverylocation, s.supplierreference
    FROM purchasing.suppliers AS s
    LEFT OUTER JOIN purchasing.suppliercategories AS sc
        ON s.suppliercategoryid = sc.suppliercategoryid
    LEFT OUTER JOIN application.people AS pp
        ON s.primarycontactpersonid = pp.personid
    LEFT OUTER JOIN application.people AS ap
        ON s.alternatecontactpersonid = ap.personid
    LEFT OUTER JOIN application.deliverymethods AS dm
        ON s.deliverymethodid = dm.deliverymethodid
    LEFT OUTER JOIN application.cities AS c
        ON s.deliverycityid = c.cityid;

CREATE OR REPLACE  VIEW website.vehicletemperatures (vehicletemperatureid, vehicleregistration, chillersensornumber, recordedwhen, temperature, fullsensordata) AS
SELECT
    vt.vehicletemperatureid, vt.vehicleregistration, vt.chillersensornumber, vt.recordedwhen, vt.temperature,
    CASE
        WHEN vt.iscompressed <> 0 THEN CAST (vt.compressedsensordata AS VARCHAR(1000))
        ELSE vt.fullsensordata
    END AS fullsensordata
    FROM warehouse.vehicletemperatures AS vt;

-- ------------ Write CREATE-INDEX-stage scripts -----------

CREATE INDEX ix_cities_fk_application_cities_stateprovinceid
ON application.cities
USING BTREE (stateprovinceid ASC);

CREATE INDEX ix_cities_archive_ix_cities_archive
ON application.cities_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_countries_archive_ix_countries_archive
ON application.countries_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_deliverymethods_archive_ix_deliverymethods_archive
ON application.deliverymethods_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_paymentmethods_archive_ix_paymentmethods_archive
ON application.paymentmethods_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_people_ix_application_people_fullname
ON application.people
USING BTREE (fullname ASC);

CREATE INDEX ix_people_ix_application_people_isemployee
ON application.people
USING BTREE (isemployee ASC);

CREATE INDEX ix_people_ix_application_people_issalesperson
ON application.people
USING BTREE (issalesperson ASC);

CREATE INDEX ix_people_ix_application_people_perf_20160301_05
ON application.people
USING BTREE (ispermittedtologon ASC, personid ASC) INCLUDE(fullname, emailaddress);

CREATE INDEX ix_people_archive_ix_people_archive
ON application.people_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_stateprovinces_fk_application_stateprovinces_countryid
ON application.stateprovinces
USING BTREE (countryid ASC);

CREATE INDEX ix_stateprovinces_ix_application_stateprovinces_salesterritory
ON application.stateprovinces
USING BTREE (salesterritory ASC);

CREATE INDEX ix_stateprovinces_archive_ix_stateprovinces_archive
ON application.stateprovinces_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_systemparameters_fk_application_systemparameters_deliverycityid
ON application.systemparameters
USING BTREE (deliverycityid ASC);

CREATE INDEX ix_systemparameters_fk_application_systemparameters_postalcityid
ON application.systemparameters
USING BTREE (postalcityid ASC);

CREATE INDEX ix_transactiontypes_archive_ix_transactiontypes_archive
ON application.transactiontypes_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_purchaseorderlines_fk_purchasing_purchaseorderlines_packagetypeid
ON purchasing.purchaseorderlines
USING BTREE (packagetypeid ASC);

CREATE INDEX ix_purchaseorderlines_fk_purchasing_purchaseorderlines_purchaseorderid
ON purchasing.purchaseorderlines
USING BTREE (purchaseorderid ASC);

CREATE INDEX ix_purchaseorderlines_fk_purchasing_purchaseorderlines_stockitemid
ON purchasing.purchaseorderlines
USING BTREE (stockitemid ASC);

CREATE INDEX ix_purchaseorderlines_ix_purchasing_purchaseorderlines_perf_20160301_4
ON purchasing.purchaseorderlines
USING BTREE (isorderlinefinalized ASC, stockitemid ASC) INCLUDE(orderedouters, receivedouters);

CREATE INDEX ix_purchaseorders_fk_purchasing_purchaseorders_contactpersonid
ON purchasing.purchaseorders
USING BTREE (contactpersonid ASC);

CREATE INDEX ix_purchaseorders_fk_purchasing_purchaseorders_deliverymethodid
ON purchasing.purchaseorders
USING BTREE (deliverymethodid ASC);

CREATE INDEX ix_purchaseorders_fk_purchasing_purchaseorders_supplierid
ON purchasing.purchaseorders
USING BTREE (supplierid ASC);

CREATE INDEX ix_suppliercategories_archive_ix_suppliercategories_archive
ON purchasing.suppliercategories_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_alternatecontactpersonid
ON purchasing.suppliers
USING BTREE (alternatecontactpersonid ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_deliverycityid
ON purchasing.suppliers
USING BTREE (deliverycityid ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_deliverymethodid
ON purchasing.suppliers
USING BTREE (deliverymethodid ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_postalcityid
ON purchasing.suppliers
USING BTREE (postalcityid ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_primarycontactpersonid
ON purchasing.suppliers
USING BTREE (primarycontactpersonid ASC);

CREATE INDEX ix_suppliers_fk_purchasing_suppliers_suppliercategoryid
ON purchasing.suppliers
USING BTREE (suppliercategoryid ASC);

CREATE INDEX ix_suppliers_archive_ix_suppliers_archive
ON purchasing.suppliers_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_suppliertransactions_cx_purchasing_suppliertransactions
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC);

CREATE INDEX ix_suppliertransactions_fk_purchasing_suppliertransactions_paymentmethodid
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC, paymentmethodid ASC);

CREATE INDEX ix_suppliertransactions_fk_purchasing_suppliertransactions_purchaseorderid
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC, purchaseorderid ASC);

CREATE INDEX ix_suppliertransactions_fk_purchasing_suppliertransactions_supplierid
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC, supplierid ASC);

CREATE INDEX ix_suppliertransactions_fk_purchasing_suppliertransactions_transactiontypeid
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC, transactiontypeid ASC);

CREATE INDEX ix_suppliertransactions_ix_purchasing_suppliertransactions_isfinalized
ON purchasing.suppliertransactions
USING BTREE (transactiondate ASC, isfinalized ASC);

CREATE INDEX ix_buyinggroups_archive_ix_buyinggroups_archive
ON sales.buyinggroups_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_customercategories_archive_ix_customercategories_archive
ON sales.customercategories_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_customers_fk_sales_customers_alternatecontactpersonid
ON sales.customers
USING BTREE (alternatecontactpersonid ASC);

CREATE INDEX ix_customers_fk_sales_customers_buyinggroupid
ON sales.customers
USING BTREE (buyinggroupid ASC);

CREATE INDEX ix_customers_fk_sales_customers_customercategoryid
ON sales.customers
USING BTREE (customercategoryid ASC);

CREATE INDEX ix_customers_fk_sales_customers_deliverycityid
ON sales.customers
USING BTREE (deliverycityid ASC);

CREATE INDEX ix_customers_fk_sales_customers_deliverymethodid
ON sales.customers
USING BTREE (deliverymethodid ASC);

CREATE INDEX ix_customers_fk_sales_customers_postalcityid
ON sales.customers
USING BTREE (postalcityid ASC);

CREATE INDEX ix_customers_fk_sales_customers_primarycontactpersonid
ON sales.customers
USING BTREE (primarycontactpersonid ASC);

CREATE INDEX ix_customers_ix_sales_customers_perf_20160301_06
ON sales.customers
USING BTREE (isoncredithold ASC, customerid ASC, billtocustomerid ASC) INCLUDE(primarycontactpersonid);

CREATE INDEX ix_customers_archive_ix_customers_archive
ON sales.customers_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_customertransactions_cx_sales_customertransactions
ON sales.customertransactions
USING BTREE (transactiondate ASC);

CREATE INDEX ix_customertransactions_fk_sales_customertransactions_customerid
ON sales.customertransactions
USING BTREE (transactiondate ASC, customerid ASC);

CREATE INDEX ix_customertransactions_fk_sales_customertransactions_invoiceid
ON sales.customertransactions
USING BTREE (transactiondate ASC, invoiceid ASC);

CREATE INDEX ix_customertransactions_fk_sales_customertransactions_paymentmethodid
ON sales.customertransactions
USING BTREE (transactiondate ASC, paymentmethodid ASC);

CREATE INDEX ix_customertransactions_fk_sales_customertransactions_transactiontypeid
ON sales.customertransactions
USING BTREE (transactiondate ASC, transactiontypeid ASC);

CREATE INDEX ix_customertransactions_ix_sales_customertransactions_isfinalized
ON sales.customertransactions
USING BTREE (transactiondate ASC, isfinalized ASC);

CREATE INDEX ix_invoicelines_fk_sales_invoicelines_invoiceid
ON sales.invoicelines
USING BTREE (invoiceid ASC);

CREATE INDEX ix_invoicelines_fk_sales_invoicelines_packagetypeid
ON sales.invoicelines
USING BTREE (packagetypeid ASC);

CREATE INDEX ix_invoicelines_fk_sales_invoicelines_stockitemid
ON sales.invoicelines
USING BTREE (stockitemid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_accountspersonid
ON sales.invoices
USING BTREE (accountspersonid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_billtocustomerid
ON sales.invoices
USING BTREE (billtocustomerid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_contactpersonid
ON sales.invoices
USING BTREE (contactpersonid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_customerid
ON sales.invoices
USING BTREE (customerid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_deliverymethodid
ON sales.invoices
USING BTREE (deliverymethodid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_orderid
ON sales.invoices
USING BTREE (orderid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_packedbypersonid
ON sales.invoices
USING BTREE (packedbypersonid ASC);

CREATE INDEX ix_invoices_fk_sales_invoices_salespersonpersonid
ON sales.invoices
USING BTREE (salespersonpersonid ASC);

CREATE INDEX ix_invoices_ix_sales_invoices_confirmeddeliverytime
ON sales.invoices
USING BTREE (confirmeddeliverytime ASC) INCLUDE(confirmedreceivedby);

CREATE INDEX ix_orderlines_fk_sales_orderlines_orderid
ON sales.orderlines
USING BTREE (orderid ASC);

CREATE INDEX ix_orderlines_fk_sales_orderlines_packagetypeid
ON sales.orderlines
USING BTREE (packagetypeid ASC);

CREATE INDEX ix_orderlines_ix_sales_orderlines_allocatedstockitems
ON sales.orderlines
USING BTREE (stockitemid ASC) INCLUDE(pickedquantity);

CREATE INDEX ix_orderlines_ix_sales_orderlines_perf_20160301_01
ON sales.orderlines
USING BTREE (pickingcompletedwhen ASC, orderid ASC, orderlineid ASC) INCLUDE(quantity, stockitemid);

CREATE INDEX ix_orderlines_ix_sales_orderlines_perf_20160301_02
ON sales.orderlines
USING BTREE (stockitemid ASC, pickingcompletedwhen ASC) INCLUDE(orderid, pickedquantity);

CREATE INDEX ix_orders_fk_sales_orders_contactpersonid
ON sales.orders
USING BTREE (contactpersonid ASC);

CREATE INDEX ix_orders_fk_sales_orders_customerid
ON sales.orders
USING BTREE (customerid ASC);

CREATE INDEX ix_orders_fk_sales_orders_pickedbypersonid
ON sales.orders
USING BTREE (pickedbypersonid ASC);

CREATE INDEX ix_orders_fk_sales_orders_salespersonpersonid
ON sales.orders
USING BTREE (salespersonpersonid ASC);

CREATE INDEX ix_specialdeals_fk_sales_specialdeals_buyinggroupid
ON sales.specialdeals
USING BTREE (buyinggroupid ASC);

CREATE INDEX ix_specialdeals_fk_sales_specialdeals_customercategoryid
ON sales.specialdeals
USING BTREE (customercategoryid ASC);

CREATE INDEX ix_specialdeals_fk_sales_specialdeals_customerid
ON sales.specialdeals
USING BTREE (customerid ASC);

CREATE INDEX ix_specialdeals_fk_sales_specialdeals_stockgroupid
ON sales.specialdeals
USING BTREE (stockgroupid ASC);

CREATE INDEX ix_specialdeals_fk_sales_specialdeals_stockitemid
ON sales.specialdeals
USING BTREE (stockitemid ASC);

CREATE INDEX ix_coldroomtemperatures_ix_warehouse_coldroomtemperatures_coldroomsensornumber
ON warehouse.coldroomtemperatures
USING BTREE (coldroomsensornumber ASC);

CREATE INDEX ix_coldroomtemperatures_archive_ix_coldroomtemperatures_archive
ON warehouse.coldroomtemperatures_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_colors_archive_ix_colors_archive
ON warehouse.colors_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_packagetypes_archive_ix_packagetypes_archive
ON warehouse.packagetypes_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_stockgroups_archive_ix_stockgroups_archive
ON warehouse.stockgroups_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_stockitems_fk_warehouse_stockitems_colorid
ON warehouse.stockitems
USING BTREE (colorid ASC);

CREATE INDEX ix_stockitems_fk_warehouse_stockitems_outerpackageid
ON warehouse.stockitems
USING BTREE (outerpackageid ASC);

CREATE INDEX ix_stockitems_fk_warehouse_stockitems_supplierid
ON warehouse.stockitems
USING BTREE (supplierid ASC);

CREATE INDEX ix_stockitems_fk_warehouse_stockitems_unitpackageid
ON warehouse.stockitems
USING BTREE (unitpackageid ASC);

CREATE INDEX ix_stockitems_archive_ix_stockitems_archive
ON warehouse.stockitems_archive
USING BTREE (validto ASC, validfrom ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_customerid
ON warehouse.stockitemtransactions
USING BTREE (customerid ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_invoiceid
ON warehouse.stockitemtransactions
USING BTREE (invoiceid ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_purchaseorderid
ON warehouse.stockitemtransactions
USING BTREE (purchaseorderid ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_stockitemid
ON warehouse.stockitemtransactions
USING BTREE (stockitemid ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_supplierid
ON warehouse.stockitemtransactions
USING BTREE (supplierid ASC);

CREATE INDEX ix_stockitemtransactions_fk_warehouse_stockitemtransactions_transactiontypeid
ON warehouse.stockitemtransactions
USING BTREE (transactiontypeid ASC);