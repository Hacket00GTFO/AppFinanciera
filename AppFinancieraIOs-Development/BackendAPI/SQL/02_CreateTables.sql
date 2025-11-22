-- =========================================
-- Script para crear las tablas
-- =========================================
-- Ejecuta este script en pgAdmin conectado a la base de datos FinancialAppDB
-- NOTA: Entity Framework creará estas tablas automáticamente,
-- este script es solo de referencia o para crear manualmente

-- =========================================
-- Tabla: Incomes (Ingresos)
-- =========================================
CREATE TABLE IF NOT EXISTS "Incomes" (
    "Id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "GrossAmount" numeric(18,2) NOT NULL,
    "NetAmount" numeric(18,2) NOT NULL,
    "Date" timestamp with time zone NOT NULL,
    "Type" text NOT NULL,
    "Description" character varying(500) NOT NULL,
    "IsRecurring" boolean NOT NULL,
    "RecurringPeriod" text,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_Incomes" PRIMARY KEY ("Id")
);

CREATE INDEX IF NOT EXISTS "IX_Incomes_Date" ON "Incomes" ("Date");

COMMENT ON TABLE "Incomes" IS 'Registro de ingresos del usuario';

-- =========================================
-- Tabla: Expenses (Gastos)
-- =========================================
CREATE TABLE IF NOT EXISTS "Expenses" (
    "Id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "Amount" numeric(18,2) NOT NULL,
    "Category" text NOT NULL,
    "Date" timestamp with time zone NOT NULL,
    "Description" character varying(500) NOT NULL,
    "IsRecurring" boolean NOT NULL,
    "RecurringPeriod" text,
    "Notes" character varying(1000),
    "ReceiptImage" text,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_Expenses" PRIMARY KEY ("Id")
);

CREATE INDEX IF NOT EXISTS "IX_Expenses_Date" ON "Expenses" ("Date");
CREATE INDEX IF NOT EXISTS "IX_Expenses_Category" ON "Expenses" ("Category");

COMMENT ON TABLE "Expenses" IS 'Registro de gastos del usuario';

-- =========================================
-- Tabla: Deductions (Deducciones)
-- =========================================
CREATE TABLE IF NOT EXISTS "Deductions" (
    "Id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "Type" text NOT NULL,
    "Amount" numeric(18,2) NOT NULL,
    "Percentage" numeric(5,2),
    "Date" timestamp with time zone NOT NULL,
    "Description" character varying(500),
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_Deductions" PRIMARY KEY ("Id")
);

CREATE INDEX IF NOT EXISTS "IX_Deductions_Date" ON "Deductions" ("Date");

COMMENT ON TABLE "Deductions" IS 'Registro de deducciones fiscales (ISR, IMSS, etc.)';

-- =========================================
-- Tabla: FinancialPeriods (Períodos Financieros)
-- =========================================
CREATE TABLE IF NOT EXISTS "FinancialPeriods" (
    "Id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "Type" text NOT NULL,
    "StartDate" timestamp with time zone NOT NULL,
    "EndDate" timestamp with time zone NOT NULL,
    "TotalIncome" numeric(18,2) NOT NULL DEFAULT 0,
    "TotalExpenses" numeric(18,2) NOT NULL DEFAULT 0,
    "TotalDeductions" numeric(18,2) NOT NULL DEFAULT 0,
    "Balance" numeric(18,2) NOT NULL DEFAULT 0,
    "IsCompleted" boolean NOT NULL DEFAULT false,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_FinancialPeriods" PRIMARY KEY ("Id")
);

CREATE INDEX IF NOT EXISTS "IX_FinancialPeriods_StartDate" ON "FinancialPeriods" ("StartDate");
CREATE INDEX IF NOT EXISTS "IX_FinancialPeriods_EndDate" ON "FinancialPeriods" ("EndDate");

COMMENT ON TABLE "FinancialPeriods" IS 'Períodos financieros (semanal, quincenal, mensual)';

-- =========================================
-- Tabla: TaxCalculations (Cálculos de Impuestos)
-- =========================================
CREATE TABLE IF NOT EXISTS "TaxCalculations" (
    "Id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "GrossSalary" numeric(18,2) NOT NULL,
    "LowerLimit" numeric(18,2) NOT NULL,
    "ExcessOverLowerLimit" numeric(18,2) NOT NULL,
    "MarginalPercentage" numeric(5,2) NOT NULL,
    "MarginalTax" numeric(18,2) NOT NULL,
    "FixedTaxQuota" numeric(18,2) NOT NULL,
    "TotalISR" numeric(18,2) NOT NULL,
    "IMSS" numeric(18,2) NOT NULL,
    "EmploymentSubsidy" numeric(18,2) NOT NULL,
    "Date" timestamp with time zone NOT NULL,
    "NetSalary" numeric(18,2) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "PK_TaxCalculations" PRIMARY KEY ("Id")
);

CREATE INDEX IF NOT EXISTS "IX_TaxCalculations_Date" ON "TaxCalculations" ("Date");

COMMENT ON TABLE "TaxCalculations" IS 'Cálculos de impuestos ISR e IMSS';

-- =========================================
-- Tabla: __EFMigrationsHistory
-- =========================================
-- Esta tabla la crea automáticamente Entity Framework
-- No necesitas crearla manualmente

