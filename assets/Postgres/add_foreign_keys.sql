-- Description: Script to create forgein keys, check constraints and triggers to Postgres after full migration \
--              from SQL-Server completed. 

--Author: Lotfy Ashmawy



------------------------Add Forgein Keys after Full load Migration ------------------------------------

ALTER TABLE application.cities
ADD CONSTRAINT pk_application_cities_418100530 PRIMARY KEY (cityid);

ALTER TABLE application.countries
ADD CONSTRAINT pk_application_countries_1477580302 PRIMARY KEY (countryid);

ALTER TABLE application.countries
ADD CONSTRAINT uq_application_countries_countryname_1509580416 UNIQUE (countryname);

ALTER TABLE application.countries
ADD CONSTRAINT uq_application_countries_formalname_1493580359 UNIQUE (formalname);

ALTER TABLE application.deliverymethods
ADD CONSTRAINT pk_application_deliverymethods_1589580701 PRIMARY KEY (deliverymethodid);

ALTER TABLE application.deliverymethods
ADD CONSTRAINT uq_application_deliverymethods_deliverymethodname_1605580758 UNIQUE (deliverymethodname);

ALTER TABLE application.paymentmethods
ADD CONSTRAINT pk_application_paymentmethods_1685581043 PRIMARY KEY (paymentmethodid);

ALTER TABLE application.paymentmethods
ADD CONSTRAINT uq_application_paymentmethods_paymentmethodname_1701581100 UNIQUE (paymentmethodname);

ALTER TABLE application.people
ADD CONSTRAINT pk_application_people_1317579732 PRIMARY KEY (personid);

ALTER TABLE application.stateprovinces
ADD CONSTRAINT pk_application_stateprovinces_306100131 PRIMARY KEY (stateprovinceid);

ALTER TABLE application.stateprovinces
ADD CONSTRAINT uq_application_stateprovinces_stateprovincename_322100188 UNIQUE (stateprovincename);

ALTER TABLE application.systemparameters
ADD CONSTRAINT pk_application_systemparameters_514100872 PRIMARY KEY (systemparameterid);

ALTER TABLE application.transactiontypes
ADD CONSTRAINT pk_application_transactiontypes_1781581385 PRIMARY KEY (transactiontypeid);

ALTER TABLE application.transactiontypes
ADD CONSTRAINT uq_application_transactiontypes_transactiontypename_1797581442 UNIQUE (transactiontypename);

ALTER TABLE purchasing.purchaseorderlines
ADD CONSTRAINT pk_purchasing_purchaseorderlines_1570104634 PRIMARY KEY (purchaseorderlineid);

ALTER TABLE purchasing.purchaseorders
ADD CONSTRAINT pk_purchasing_purchaseorders_1042102753 PRIMARY KEY (purchaseorderid);

ALTER TABLE purchasing.suppliercategories
ADD CONSTRAINT pk_purchasing_suppliercategories_1877581727 PRIMARY KEY (suppliercategoryid);

ALTER TABLE purchasing.suppliercategories
ADD CONSTRAINT uq_purchasing_suppliercategories_suppliercategoryname_1893581784 UNIQUE (suppliercategoryname);

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT pk_purchasing_suppliers_626101271 PRIMARY KEY (supplierid);

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT uq_purchasing_suppliers_suppliername_642101328 UNIQUE (suppliername);

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT pk_purchasing_suppliertransactions_1451152215 PRIMARY KEY (suppliertransactionid);

ALTER TABLE sales.buyinggroups
ADD CONSTRAINT pk_sales_buyinggroups_1973582069 PRIMARY KEY (buyinggroupid);

ALTER TABLE sales.buyinggroups
ADD CONSTRAINT uq_sales_buyinggroups_buyinggroupname_1989582126 UNIQUE (buyinggroupname);

ALTER TABLE sales.customercategories
ADD CONSTRAINT pk_sales_customercategories_2069582411 PRIMARY KEY (customercategoryid);

ALTER TABLE sales.customercategories
ADD CONSTRAINT uq_sales_customercategories_customercategoryname_2085582468 UNIQUE (customercategoryname);

ALTER TABLE sales.customers
ADD CONSTRAINT pk_sales_customers_818101955 PRIMARY KEY (customerid);

ALTER TABLE sales.customers
ADD CONSTRAINT uq_sales_customers_customername_834102012 UNIQUE (customername);

ALTER TABLE sales.customertransactions
ADD CONSTRAINT pk_sales_customertransactions_1435152158 PRIMARY KEY (customertransactionid);

ALTER TABLE sales.invoicelines
ADD CONSTRAINT pk_sales_invoicelines_526624919 PRIMARY KEY (invoicelineid);

ALTER TABLE sales.invoices
ADD CONSTRAINT pk_sales_invoices_2034106287 PRIMARY KEY (invoiceid);

ALTER TABLE sales.orderlines
ADD CONSTRAINT pk_sales_orderlines_110623437 PRIMARY KEY (orderlineid);

ALTER TABLE sales.orders
ADD CONSTRAINT pk_sales_orders_1170103209 PRIMARY KEY (orderid);

ALTER TABLE sales.specialdeals
ADD CONSTRAINT ck_sales_specialdeals_exactly_one_not_null_pricing_option_is_required_1986106116 CHECK (
(((CASE
    WHEN discountamount IS NULL THEN (0)
    ELSE (1)
END +
CASE
    WHEN discountpercentage IS NULL THEN (0)
    ELSE (1)
END) +
CASE
    WHEN unitprice IS NULL THEN (0)
    ELSE (1)
END) = (1)));

ALTER TABLE sales.specialdeals
ADD CONSTRAINT ck_sales_specialdeals_unit_price_deal_requires_special_stockitem_2002106173 CHECK (
(stockitemid IS NOT NULL AND unitprice IS NOT NULL OR unitprice IS NULL));

ALTER TABLE sales.specialdeals
ADD CONSTRAINT pk_sales_specialdeals_1842105603 PRIMARY KEY (specialdealid);

ALTER TABLE warehouse.coldroomtemperatures
ADD CONSTRAINT pk_warehouse_coldroomtemperatures_1195151303 PRIMARY KEY (coldroomtemperatureid);

ALTER TABLE warehouse.colors
ADD CONSTRAINT pk_warehouse_colors_18099105 PRIMARY KEY (colorid);

ALTER TABLE warehouse.colors
ADD CONSTRAINT uq_warehouse_colors_colorname_34099162 UNIQUE (colorname);

ALTER TABLE warehouse.packagetypes
ADD CONSTRAINT pk_warehouse_packagetypes_114099447 PRIMARY KEY (packagetypeid);

ALTER TABLE warehouse.packagetypes
ADD CONSTRAINT uq_warehouse_packagetypes_packagetypename_130099504 UNIQUE (packagetypename);

ALTER TABLE warehouse.stockgroups
ADD CONSTRAINT pk_warehouse_stockgroups_210099789 PRIMARY KEY (stockgroupid);

ALTER TABLE warehouse.stockgroups
ADD CONSTRAINT uq_warehouse_stockgroups_stockgroupname_226099846 UNIQUE (stockgroupname);

ALTER TABLE warehouse.stockitemholdings
ADD CONSTRAINT pk_warehouse_stockitemholdings_1490104349 PRIMARY KEY (stockitemid);

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT pk_warehouse_stockitems_1330103779 PRIMARY KEY (stockitemid);

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT uq_warehouse_stockitems_stockitemname_1346103836 UNIQUE (stockitemname);

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT pk_warehouse_stockitemstockgroups_238623893 PRIMARY KEY (stockitemstockgroupid);

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT uq_stockitemstockgroups_stockgroupid_lookup_350624292 UNIQUE (stockgroupid, stockitemid);

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT uq_stockitemstockgroups_stockitemid_lookup_334624235 UNIQUE (stockitemid, stockgroupid);

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT pk_warehouse_stockitemtransactions_1163151189 PRIMARY KEY (stockitemtransactionid);

ALTER TABLE warehouse.vehicletemperatures
ADD CONSTRAINT pk_warehouse_vehicletemperatures_1259151531 PRIMARY KEY (vehicletemperatureid);

-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE application.cities
ADD CONSTRAINT fk_application_cities_application_people_466100701 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.cities
ADD CONSTRAINT fk_application_cities_stateprovinceid_application_stateprovinces_450100644 FOREIGN KEY (stateprovinceid) 
REFERENCES application.stateprovinces (stateprovinceid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.countries
ADD CONSTRAINT fk_application_countries_application_people_1541580530 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.deliverymethods
ADD CONSTRAINT fk_application_deliverymethods_application_people_1637580872 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.paymentmethods
ADD CONSTRAINT fk_application_paymentmethods_application_people_1733581214 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.people
ADD CONSTRAINT fk_application_people_application_people_1349579846 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.stateprovinces
ADD CONSTRAINT fk_application_stateprovinces_application_people_370100359 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.stateprovinces
ADD CONSTRAINT fk_application_stateprovinces_countryid_application_countries_354100302 FOREIGN KEY (countryid) 
REFERENCES application.countries (countryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.systemparameters
ADD CONSTRAINT fk_application_systemparameters_application_people_578101100 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.systemparameters
ADD CONSTRAINT fk_application_systemparameters_deliverycityid_application_cities_546100986 FOREIGN KEY (deliverycityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.systemparameters
ADD CONSTRAINT fk_application_systemparameters_postalcityid_application_cities_562101043 FOREIGN KEY (postalcityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE application.transactiontypes
ADD CONSTRAINT fk_application_transactiontypes_application_people_1829581556 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorderlines
ADD CONSTRAINT fk_purchasing_purchaseorderlines_application_people_1650104919 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorderlines
ADD CONSTRAINT fk_purchasing_purchaseorderlines_packagetypeid_warehouse_packagetypes_1634104862 FOREIGN KEY (packagetypeid) 
REFERENCES warehouse.packagetypes (packagetypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorderlines
ADD CONSTRAINT fk_purchasing_purchaseorderlines_purchaseorderid_purchasing_purchaseorders_1602104748 FOREIGN KEY (purchaseorderid) 
REFERENCES purchasing.purchaseorders (purchaseorderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorderlines
ADD CONSTRAINT fk_purchasing_purchaseorderlines_stockitemid_warehouse_stockitems_1618104805 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorders
ADD CONSTRAINT fk_purchasing_purchaseorders_application_people_1122103038 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorders
ADD CONSTRAINT fk_purchasing_purchaseorders_contactpersonid_application_people_1106102981 FOREIGN KEY (contactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorders
ADD CONSTRAINT fk_purchasing_purchaseorders_deliverymethodid_application_deliverymethods_1090102924 FOREIGN KEY (deliverymethodid) 
REFERENCES application.deliverymethods (deliverymethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.purchaseorders
ADD CONSTRAINT fk_purchasing_purchaseorders_supplierid_purchasing_suppliers_1074102867 FOREIGN KEY (supplierid) 
REFERENCES purchasing.suppliers (supplierid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliercategories
ADD CONSTRAINT fk_purchasing_suppliercategories_application_people_1925581898 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_alternatecontactpersonid_application_people_706101556 FOREIGN KEY (alternatecontactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_application_people_770101784 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_deliverycityid_application_cities_738101670 FOREIGN KEY (deliverycityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_deliverymethodid_application_deliverymethods_722101613 FOREIGN KEY (deliverymethodid) 
REFERENCES application.deliverymethods (deliverymethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_postalcityid_application_cities_754101727 FOREIGN KEY (postalcityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_primarycontactpersonid_application_people_690101499 FOREIGN KEY (primarycontactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliers
ADD CONSTRAINT fk_purchasing_suppliers_suppliercategoryid_purchasing_suppliercategories_674101442 FOREIGN KEY (suppliercategoryid) 
REFERENCES purchasing.suppliercategories (suppliercategoryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT fk_purchasing_suppliertransactions_application_people_1794105432 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT fk_purchasing_suppliertransactions_paymentmethodid_application_paymentmethods_1778105375 FOREIGN KEY (paymentmethodid) 
REFERENCES application.paymentmethods (paymentmethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT fk_purchasing_suppliertransactions_purchaseorderid_purchasing_purchaseorders_1762105318 FOREIGN KEY (purchaseorderid) 
REFERENCES purchasing.purchaseorders (purchaseorderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT fk_purchasing_suppliertransactions_supplierid_purchasing_suppliers_1730105204 FOREIGN KEY (supplierid) 
REFERENCES purchasing.suppliers (supplierid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE purchasing.suppliertransactions
ADD CONSTRAINT fk_purchasing_suppliertransactions_transactiontypeid_application_transactiontypes_1746105261 FOREIGN KEY (transactiontypeid) 
REFERENCES application.transactiontypes (transactiontypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.buyinggroups
ADD CONSTRAINT fk_sales_buyinggroups_application_people_2021582240 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customercategories
ADD CONSTRAINT fk_sales_customercategories_application_people_2117582582 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_alternatecontactpersonid_application_people_930102354 FOREIGN KEY (alternatecontactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_application_people_994102582 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_billtocustomerid_sales_customers_866102126 FOREIGN KEY (billtocustomerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_buyinggroupid_sales_buyinggroups_898102240 FOREIGN KEY (buyinggroupid) 
REFERENCES sales.buyinggroups (buyinggroupid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_customercategoryid_sales_customercategories_882102183 FOREIGN KEY (customercategoryid) 
REFERENCES sales.customercategories (customercategoryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_deliverycityid_application_cities_962102468 FOREIGN KEY (deliverycityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_deliverymethodid_application_deliverymethods_946102411 FOREIGN KEY (deliverymethodid) 
REFERENCES application.deliverymethods (deliverymethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_postalcityid_application_cities_978102525 FOREIGN KEY (postalcityid) 
REFERENCES application.cities (cityid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customers
ADD CONSTRAINT fk_sales_customers_primarycontactpersonid_application_people_914102297 FOREIGN KEY (primarycontactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customertransactions
ADD CONSTRAINT fk_sales_customertransactions_application_people_478624748 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customertransactions
ADD CONSTRAINT fk_sales_customertransactions_customerid_sales_customers_414624520 FOREIGN KEY (customerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customertransactions
ADD CONSTRAINT fk_sales_customertransactions_invoiceid_sales_invoices_446624634 FOREIGN KEY (invoiceid) 
REFERENCES sales.invoices (invoiceid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customertransactions
ADD CONSTRAINT fk_sales_customertransactions_paymentmethodid_application_paymentmethods_462624691 FOREIGN KEY (paymentmethodid) 
REFERENCES application.paymentmethods (paymentmethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.customertransactions
ADD CONSTRAINT fk_sales_customertransactions_transactiontypeid_application_transactiontypes_430624577 FOREIGN KEY (transactiontypeid) 
REFERENCES application.transactiontypes (transactiontypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoicelines
ADD CONSTRAINT fk_sales_invoicelines_application_people_606625204 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoicelines
ADD CONSTRAINT fk_sales_invoicelines_invoiceid_sales_invoices_558625033 FOREIGN KEY (invoiceid) 
REFERENCES sales.invoices (invoiceid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoicelines
ADD CONSTRAINT fk_sales_invoicelines_packagetypeid_warehouse_packagetypes_590625147 FOREIGN KEY (packagetypeid) 
REFERENCES warehouse.packagetypes (packagetypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoicelines
ADD CONSTRAINT fk_sales_invoicelines_stockitemid_warehouse_stockitems_574625090 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_accountspersonid_application_people_2146106686 FOREIGN KEY (accountspersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_application_people_46623209 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_billtocustomerid_sales_customers_2082106458 FOREIGN KEY (billtocustomerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_contactpersonid_application_people_2130106629 FOREIGN KEY (contactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_customerid_sales_customers_2066106401 FOREIGN KEY (customerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_deliverymethodid_application_deliverymethods_2114106572 FOREIGN KEY (deliverymethodid) 
REFERENCES application.deliverymethods (deliverymethodid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_orderid_sales_orders_2098106515 FOREIGN KEY (orderid) 
REFERENCES sales.orders (orderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_packedbypersonid_application_people_30623152 FOREIGN KEY (packedbypersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.invoices
ADD CONSTRAINT fk_sales_invoices_salespersonpersonid_application_people_14623095 FOREIGN KEY (salespersonpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orderlines
ADD CONSTRAINT fk_sales_orderlines_application_people_190623722 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orderlines
ADD CONSTRAINT fk_sales_orderlines_orderid_sales_orders_142623551 FOREIGN KEY (orderid) 
REFERENCES sales.orders (orderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orderlines
ADD CONSTRAINT fk_sales_orderlines_packagetypeid_warehouse_packagetypes_174623665 FOREIGN KEY (packagetypeid) 
REFERENCES warehouse.packagetypes (packagetypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orderlines
ADD CONSTRAINT fk_sales_orderlines_stockitemid_warehouse_stockitems_158623608 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_application_people_1282103608 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_backorderorderid_sales_orders_1266103551 FOREIGN KEY (backorderorderid) 
REFERENCES sales.orders (orderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_contactpersonid_application_people_1250103494 FOREIGN KEY (contactpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_customerid_sales_customers_1202103323 FOREIGN KEY (customerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_pickedbypersonid_application_people_1234103437 FOREIGN KEY (pickedbypersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.orders
ADD CONSTRAINT fk_sales_orders_salespersonpersonid_application_people_1218103380 FOREIGN KEY (salespersonpersonid) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_application_people_1954106002 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_buyinggroupid_sales_buyinggroups_1906105831 FOREIGN KEY (buyinggroupid) 
REFERENCES sales.buyinggroups (buyinggroupid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_customercategoryid_sales_customercategories_1922105888 FOREIGN KEY (customercategoryid) 
REFERENCES sales.customercategories (customercategoryid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_customerid_sales_customers_1890105774 FOREIGN KEY (customerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_stockgroupid_warehouse_stockgroups_1938105945 FOREIGN KEY (stockgroupid) 
REFERENCES warehouse.stockgroups (stockgroupid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE sales.specialdeals
ADD CONSTRAINT fk_sales_specialdeals_stockitemid_warehouse_stockitems_1874105717 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.colors
ADD CONSTRAINT fk_warehouse_colors_application_people_66099276 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.packagetypes
ADD CONSTRAINT fk_warehouse_packagetypes_application_people_162099618 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockgroups
ADD CONSTRAINT fk_warehouse_stockgroups_application_people_258099960 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemholdings
ADD CONSTRAINT fk_warehouse_stockitemholdings_application_people_1522104463 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemholdings
ADD CONSTRAINT pkfk_warehouse_stockitemholdings_stockitemid_warehouse_stockitems_1506104406 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT fk_warehouse_stockitems_application_people_1442104178 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT fk_warehouse_stockitems_colorid_warehouse_colors_1394104007 FOREIGN KEY (colorid) 
REFERENCES warehouse.colors (colorid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT fk_warehouse_stockitems_outerpackageid_warehouse_packagetypes_1426104121 FOREIGN KEY (outerpackageid) 
REFERENCES warehouse.packagetypes (packagetypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT fk_warehouse_stockitems_supplierid_purchasing_suppliers_1378103950 FOREIGN KEY (supplierid) 
REFERENCES purchasing.suppliers (supplierid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitems
ADD CONSTRAINT fk_warehouse_stockitems_unitpackageid_warehouse_packagetypes_1410104064 FOREIGN KEY (unitpackageid) 
REFERENCES warehouse.packagetypes (packagetypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT fk_warehouse_stockitemstockgroups_application_people_302624121 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT fk_warehouse_stockitemstockgroups_stockgroupid_warehouse_stockgroups_286624064 FOREIGN KEY (stockgroupid) 
REFERENCES warehouse.stockgroups (stockgroupid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemstockgroups
ADD CONSTRAINT fk_warehouse_stockitemstockgroups_stockitemid_warehouse_stockitems_270624007 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_application_people_782625831 FOREIGN KEY (lasteditedby) 
REFERENCES application.people (personid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_customerid_sales_customers_718625603 FOREIGN KEY (customerid) 
REFERENCES sales.customers (customerid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_invoiceid_sales_invoices_734625660 FOREIGN KEY (invoiceid) 
REFERENCES sales.invoices (invoiceid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_purchaseorderid_purchasing_purchaseorders_766625774 FOREIGN KEY (purchaseorderid) 
REFERENCES purchasing.purchaseorders (purchaseorderid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_stockitemid_warehouse_stockitems_686625489 FOREIGN KEY (stockitemid) 
REFERENCES warehouse.stockitems (stockitemid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_supplierid_purchasing_suppliers_750625717 FOREIGN KEY (supplierid) 
REFERENCES purchasing.suppliers (supplierid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE warehouse.stockitemtransactions
ADD CONSTRAINT fk_warehouse_stockitemtransactions_transactiontypeid_application_transactiontypes_702625546 FOREIGN KEY (transactiontypeid) 
REFERENCES application.transactiontypes (transactiontypeid)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

-- ------------ Write CREATE-TRIGGER-stage scripts -----------

CREATE TRIGGER tr_hist_cities
BEFORE INSERT OR UPDATE OR DELETE
ON application.cities
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_cities();

CREATE TRIGGER tr_hist_countries
BEFORE INSERT OR UPDATE OR DELETE
ON application.countries
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_countries();

CREATE TRIGGER tr_hist_deliverymethods
BEFORE INSERT OR UPDATE OR DELETE
ON application.deliverymethods
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_deliverymethods();

CREATE TRIGGER tr_hist_paymentmethods
BEFORE INSERT OR UPDATE OR DELETE
ON application.paymentmethods
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_paymentmethods();

CREATE TRIGGER tr_hist_people
BEFORE INSERT OR UPDATE OR DELETE
ON application.people
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_people();

CREATE TRIGGER tr_people_biu
BEFORE INSERT OR UPDATE
ON application.people
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_people_biu();

CREATE TRIGGER tr_hist_stateprovinces
BEFORE INSERT OR UPDATE OR DELETE
ON application.stateprovinces
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_stateprovinces();

CREATE TRIGGER tr_hist_transactiontypes
BEFORE INSERT OR UPDATE OR DELETE
ON application.transactiontypes
FOR EACH ROW
EXECUTE PROCEDURE application.fn_tr_hist_transactiontypes();

CREATE TRIGGER tr_hist_suppliercategories
BEFORE INSERT OR UPDATE OR DELETE
ON purchasing.suppliercategories
FOR EACH ROW
EXECUTE PROCEDURE purchasing.fn_tr_hist_suppliercategories();

CREATE TRIGGER tr_hist_suppliers
BEFORE INSERT OR UPDATE OR DELETE
ON purchasing.suppliers
FOR EACH ROW
EXECUTE PROCEDURE purchasing.fn_tr_hist_suppliers();

CREATE TRIGGER tr_hist_buyinggroups
BEFORE INSERT OR UPDATE OR DELETE
ON sales.buyinggroups
FOR EACH ROW
EXECUTE PROCEDURE sales.fn_tr_hist_buyinggroups();

CREATE TRIGGER tr_hist_customercategories
BEFORE INSERT OR UPDATE OR DELETE
ON sales.customercategories
FOR EACH ROW
EXECUTE PROCEDURE sales.fn_tr_hist_customercategories();

CREATE TRIGGER tr_hist_customers
BEFORE INSERT OR UPDATE OR DELETE
ON sales.customers
FOR EACH ROW
EXECUTE PROCEDURE sales.fn_tr_hist_customers();

CREATE TRIGGER tr_invoices_biu
BEFORE INSERT OR UPDATE
ON sales.invoices
FOR EACH ROW
EXECUTE PROCEDURE sales.fn_tr_invoices_biu();

CREATE TRIGGER tr_hist_coldroomtemperatures
BEFORE INSERT OR UPDATE OR DELETE
ON warehouse.coldroomtemperatures
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_hist_coldroomtemperatures();

CREATE TRIGGER tr_hist_colors
BEFORE INSERT OR UPDATE OR DELETE
ON warehouse.colors
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_hist_colors();

CREATE TRIGGER tr_hist_packagetypes
BEFORE INSERT OR UPDATE OR DELETE
ON warehouse.packagetypes
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_hist_packagetypes();

CREATE TRIGGER tr_hist_stockgroups
BEFORE INSERT OR UPDATE OR DELETE
ON warehouse.stockgroups
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_hist_stockgroups();

CREATE TRIGGER tr_hist_stockitems
BEFORE INSERT OR UPDATE OR DELETE
ON warehouse.stockitems
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_hist_stockitems();

CREATE TRIGGER tr_stockitems_biu
BEFORE INSERT OR UPDATE
ON warehouse.stockitems
FOR EACH ROW
EXECUTE PROCEDURE warehouse.fn_tr_stockitems_biu();