using System;

namespace BackendAPI.Models
{
    public enum ExpenseCategory
    {
        // Fijos obligatorios
        Rent = 0,
        Loans = 1,
        Taxes = 2,
        Others = 3,
        
        // Fijos reducibles
        Water = 4,
        Gas = 5,
        Electricity = 6,
        Internet = 7,
        Food = 8,
        Transport = 9,
        Education = 10,
        Contingencies = 11,
        
        // Variables
        Leisure = 12,
        Travel = 13,
        Subscriptions = 14,
        OtherExpenses = 15
    }
    
    public static class ExpenseCategoryExtensions
    {
        public static string GetDisplayName(this ExpenseCategory category)
        {
            return category switch
            {
                ExpenseCategory.Rent => "Alquiler/Hipoteca",
                ExpenseCategory.Loans => "Préstamos",
                ExpenseCategory.Taxes => "Impuestos",
                ExpenseCategory.Others => "Otros",
                ExpenseCategory.Water => "Agua",
                ExpenseCategory.Gas => "Gas",
                ExpenseCategory.Electricity => "Luz",
                ExpenseCategory.Internet => "Internet + Tel + TV",
                ExpenseCategory.Food => "Alimentación",
                ExpenseCategory.Transport => "Transporte",
                ExpenseCategory.Education => "Escolares",
                ExpenseCategory.Contingencies => "Imprevistos",
                ExpenseCategory.Leisure => "Ocio",
                ExpenseCategory.Travel => "Viajes",
                ExpenseCategory.Subscriptions => "Suscripciones",
                ExpenseCategory.OtherExpenses => "Otros Gastos",
                _ => category.ToString()
            };
        }
        
        public static bool IsMandatory(this ExpenseCategory category)
        {
            return category is ExpenseCategory.Rent or 
                   ExpenseCategory.Loans or 
                   ExpenseCategory.Taxes or 
                   ExpenseCategory.Others;
        }
        
        public static bool IsReducible(this ExpenseCategory category)
        {
            return category is ExpenseCategory.Water or 
                   ExpenseCategory.Gas or 
                   ExpenseCategory.Electricity or 
                   ExpenseCategory.Internet or 
                   ExpenseCategory.Food or 
                   ExpenseCategory.Transport or 
                   ExpenseCategory.Education or 
                   ExpenseCategory.Contingencies;
        }
        
        public static bool IsVariable(this ExpenseCategory category)
        {
            return category is ExpenseCategory.Leisure or 
                   ExpenseCategory.Travel or 
                   ExpenseCategory.Subscriptions or 
                   ExpenseCategory.OtherExpenses;
        }
    }
}

