-- =========================================
-- Script para insertar datos de ejemplo
-- =========================================
-- Ejecuta este script en pgAdmin conectado a la base de datos FinancialAppDB
-- OPCIONAL: Solo para pruebas y desarrollo

-- =========================================
-- Datos de ejemplo: Incomes
-- =========================================
INSERT INTO "Incomes" ("Id", "GrossAmount", "NetAmount", "Date", "Type", "Description", "IsRecurring", "RecurringPeriod", "CreatedAt", "UpdatedAt")
VALUES 
    (gen_random_uuid(), 50000.00, 42000.00, '2024-10-01', 'Employment', 'Salario mensual Octubre', true, 'Monthly', now(), now()),
    (gen_random_uuid(), 15000.00, 15000.00, '2024-10-15', 'Freelance', 'Proyecto de desarrollo web', false, NULL, now(), now()),
    (gen_random_uuid(), 5000.00, 5000.00, '2024-10-20', 'Investment', 'Dividendos de acciones', false, NULL, now(), now());

-- =========================================
-- Datos de ejemplo: Expenses
-- =========================================
INSERT INTO "Expenses" ("Id", "Amount", "Category", "Date", "Description", "IsRecurring", "RecurringPeriod", "Notes", "CreatedAt", "UpdatedAt")
VALUES 
    (gen_random_uuid(), 8000.00, 'Rent', '2024-10-01', 'Renta departamento', true, 'Monthly', 'Pago mensual de renta', now(), now()),
    (gen_random_uuid(), 5000.00, 'Food', '2024-10-05', 'Despensa mensual', true, 'Monthly', 'Compra en supermercado', now(), now()),
    (gen_random_uuid(), 800.00, 'Electricity', '2024-10-10', 'Recibo de luz', true, 'Biweekly', 'CFE', now(), now()),
    (gen_random_uuid(), 500.00, 'Internet', '2024-10-01', 'Internet + TV', true, 'Monthly', 'Paquete Totalplay', now(), now()),
    (gen_random_uuid(), 2000.00, 'Transport', '2024-10-01', 'Gasolina', true, 'Weekly', 'Gasolina semanal', now(), now()),
    (gen_random_uuid(), 1500.00, 'Leisure', '2024-10-12', 'Cena con amigos', false, NULL, 'Restaurante', now(), now()),
    (gen_random_uuid(), 300.00, 'Subscriptions', '2024-10-01', 'Netflix + Spotify', true, 'Monthly', 'Suscripciones digitales', now(), now());

-- =========================================
-- Datos de ejemplo: Deductions
-- =========================================
INSERT INTO "Deductions" ("Id", "Type", "Amount", "Percentage", "Date", "Description", "CreatedAt", "UpdatedAt")
VALUES 
    (gen_random_uuid(), 'ISR', 8000.00, 16.00, '2024-10-01', 'Impuesto sobre la renta', now(), now()),
    (gen_random_uuid(), 'IMSS', 1375.00, 2.75, '2024-10-01', 'Seguro social', now(), now());

-- =========================================
-- Datos de ejemplo: FinancialPeriods
-- =========================================
INSERT INTO "FinancialPeriods" ("Id", "Type", "StartDate", "EndDate", "TotalIncome", "TotalExpenses", "TotalDeductions", "Balance", "IsCompleted", "CreatedAt", "UpdatedAt")
VALUES 
    (gen_random_uuid(), 'Monthly', '2024-10-01', '2024-10-30', 70000.00, 18100.00, 9375.00, 42525.00, false, now(), now()),
    (gen_random_uuid(), 'Monthly', '2024-09-01', '2024-09-30', 50000.00, 15000.00, 9375.00, 25625.00, true, now(), now());

-- =========================================
-- Datos de ejemplo: TaxCalculations
-- =========================================
INSERT INTO "TaxCalculations" ("Id", "GrossSalary", "LowerLimit", "ExcessOverLowerLimit", "MarginalPercentage", "MarginalTax", "FixedTaxQuota", "TotalISR", "IMSS", "EmploymentSubsidy", "Date", "NetSalary", "CreatedAt", "UpdatedAt")
VALUES 
    (gen_random_uuid(), 50000.00, 15487.72, 34512.28, 21.36, 7371.82, 1640.18, 9012.00, 1375.00, 0.00, '2024-10-01', 39613.00, now(), now());

-- =========================================
-- Verificar datos insertados
-- =========================================
SELECT COUNT(*) as total_incomes FROM "Incomes";
SELECT COUNT(*) as total_expenses FROM "Expenses";
SELECT COUNT(*) as total_deductions FROM "Deductions";
SELECT COUNT(*) as total_periods FROM "FinancialPeriods";
SELECT COUNT(*) as total_tax_calculations FROM "TaxCalculations";

