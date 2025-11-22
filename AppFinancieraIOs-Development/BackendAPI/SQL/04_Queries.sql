-- =========================================
-- Consultas útiles para verificar y analizar datos
-- =========================================

-- =========================================
-- Consultas de verificación
-- =========================================

-- Ver todos los ingresos
SELECT * FROM "Incomes" ORDER BY "Date" DESC;

-- Ver todos los gastos
SELECT * FROM "Expenses" ORDER BY "Date" DESC;

-- Ver todas las deducciones
SELECT * FROM "Deductions" ORDER BY "Date" DESC;

-- Ver todos los períodos financieros
SELECT * FROM "FinancialPeriods" ORDER BY "StartDate" DESC;

-- Ver todos los cálculos de impuestos
SELECT * FROM "TaxCalculations" ORDER BY "Date" DESC;

-- =========================================
-- Resúmenes y estadísticas
-- =========================================

-- Resumen de ingresos por tipo
SELECT 
    "Type",
    COUNT(*) as cantidad,
    SUM("GrossAmount") as total_bruto,
    SUM("NetAmount") as total_neto,
    AVG("GrossAmount") as promedio_bruto
FROM "Incomes"
GROUP BY "Type"
ORDER BY total_bruto DESC;

-- Resumen de gastos por categoría
SELECT 
    "Category",
    COUNT(*) as cantidad,
    SUM("Amount") as total,
    AVG("Amount") as promedio
FROM "Expenses"
GROUP BY "Category"
ORDER BY total DESC;

-- Gastos recurrentes vs no recurrentes
SELECT 
    "IsRecurring",
    COUNT(*) as cantidad,
    SUM("Amount") as total
FROM "Expenses"
GROUP BY "IsRecurring";

-- Resumen de deducciones por tipo
SELECT 
    "Type",
    COUNT(*) as cantidad,
    SUM("Amount") as total,
    AVG("Percentage") as porcentaje_promedio
FROM "Deductions"
GROUP BY "Type"
ORDER BY total DESC;

-- =========================================
-- Análisis por fecha
-- =========================================

-- Ingresos del mes actual
SELECT * FROM "Incomes"
WHERE "Date" >= date_trunc('month', CURRENT_DATE)
  AND "Date" < date_trunc('month', CURRENT_DATE) + interval '1 month'
ORDER BY "Date" DESC;

-- Gastos del mes actual
SELECT * FROM "Expenses"
WHERE "Date" >= date_trunc('month', CURRENT_DATE)
  AND "Date" < date_trunc('month', CURRENT_DATE) + interval '1 month'
ORDER BY "Date" DESC;

-- Balance mensual
SELECT 
    date_trunc('month', "Date") as mes,
    SUM("GrossAmount") as ingresos_brutos,
    SUM("NetAmount") as ingresos_netos
FROM "Incomes"
GROUP BY mes
ORDER BY mes DESC;

-- =========================================
-- Consultas avanzadas
-- =========================================

-- Top 5 categorías de gastos
SELECT 
    "Category",
    SUM("Amount") as total
FROM "Expenses"
GROUP BY "Category"
ORDER BY total DESC
LIMIT 5;

-- Gastos recurrentes mensuales proyectados
SELECT 
    "Category",
    SUM("Amount") as total_mensual
FROM "Expenses"
WHERE "IsRecurring" = true AND "RecurringPeriod" = 'Monthly'
GROUP BY "Category"
ORDER BY total_mensual DESC;

-- Balance del período actual
SELECT 
    "Type",
    "StartDate",
    "EndDate",
    "TotalIncome",
    "TotalExpenses",
    "TotalDeductions",
    "Balance",
    "IsCompleted"
FROM "FinancialPeriods"
WHERE "StartDate" <= CURRENT_DATE AND "EndDate" >= CURRENT_DATE;

-- =========================================
-- Limpieza de datos (usar con cuidado)
-- =========================================

-- Eliminar todos los datos de las tablas (mantiene la estructura)
-- CUIDADO: Esto borrará todos los datos
/*
TRUNCATE TABLE "Incomes" CASCADE;
TRUNCATE TABLE "Expenses" CASCADE;
TRUNCATE TABLE "Deductions" CASCADE;
TRUNCATE TABLE "FinancialPeriods" CASCADE;
TRUNCATE TABLE "TaxCalculations" CASCADE;
*/

-- Eliminar datos de prueba más antiguos de 1 año
/*
DELETE FROM "Incomes" WHERE "Date" < CURRENT_DATE - interval '1 year';
DELETE FROM "Expenses" WHERE "Date" < CURRENT_DATE - interval '1 year';
DELETE FROM "Deductions" WHERE "Date" < CURRENT_DATE - interval '1 year';
DELETE FROM "TaxCalculations" WHERE "Date" < CURRENT_DATE - interval '1 year';
*/

