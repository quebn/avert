import "package:avert/core/documents/company/document.dart";

import "document.dart";

// MARK: Liabilities
List<Account> createAssets(Company company) {
  return [
    Account.parent(
      root: AccountRoot.asset,
      name: "Curent Assets",
      company: company,
      children: createCurrentAssets(company),
    ),
    Account.parent(
      root: AccountRoot.asset,
      name: "Non-current Assets",
      company: company,
      children: [
      ],
    ),
  ];
}

List<Account> createCurrentAssets(Company company) {
  return [
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Cash and cash equivalents",
      children: [
        Account.asset(
          company: company,
          name: "Bank",
          type: AccountType.bank,
        ),
        Account.asset(
          company: company,
          name: "Cash",
          type: AccountType.cash,
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Receivables",
      type: AccountType.receivable,
      children: [
        Account.asset(
          company: company,
          name: "Cash Advances to Suppliers",
          type: AccountType.receivable,
        ),
        Account.asset(
          company: company,
          name: "Accounts Receivable",
          type: AccountType.receivable,
        ),
      ]
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Stock",
      type: AccountType.inventory,
      children: [
        Account.asset(
          company: company,
          name: "Inventory",
          type: AccountType.inventory,
        ),
        Account.asset(
          company: company,
          name: "Merchandise",
          type: AccountType.inventory,
        ),
      ],
    ),
  ];
}

List<Account> createNoncurrentAssets(Company company) {
  return [
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Property Plant and Equipment",
      type: AccountType.fixedAsset,
      children: createPPEAssets (company),
    ),
  ];
}

List<Account> createPPEAssets(Company company) {
  return [
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Land",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Land - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Land - Development",
          type: AccountType.fixedAsset,
        ),
      ]
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Machinery",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Equipment - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Equipment - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Tools",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Tools - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Tools - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Buildings",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Buildings - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Buildings - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Devices",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Devices - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Devices - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.asset,
      company: company,
      name: "Vehicles",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          company: company,
          name: "Vehicles - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          company: company,
          name: "Vehicles - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.asset(
      company: company,
      name: "Capital Work in Progress",
      type: AccountType.cwip,
    )
  ];
}

// MARK: Liabilities
List<Account> createLiabilities(Company company) {
  return [
    Account.parent(
      root: AccountRoot.liability,
      name: "Curent liabilities",
      company: company,
      children: createLiabilities(company),
    ),
    Account.parent(
      root: AccountRoot.liability,
      name: "Non-current Liabilities",
      company: company,
      children: createNoncurrentLiabilities(company),
    ),
  ];
}

List<Account> createCurrentLiabilities(Company company) {
  return [
    Account.parent(
      root: AccountRoot.liability,
      company: company,
      name: "Payables",
      type: AccountType.payable,
      children: [
        Account.liability(
          company: company,
          name: "Cash Advances from Customers",
          type: AccountType.payable,
        ),
        Account.liability(
          company: company,
          name: "Accounts Payable",
          type: AccountType.payable,
        ),
        Account.liability(
          company: company,
          name: "Wages Payable",
          type: AccountType.payable,
        ),
        Account.liability(
          company: company,
          name: "Tax Payable",
          type: AccountType.payable,
        ),
      ]
    ),
  ];
}

List<Account> createNoncurrentLiabilities(Company company) {
  return [];
}

// MARK: Equity
List<Account> createEquity(Company company) {
  return [
    Account.equity(
      name: "Retained Earnings",
      company: company
    ),
    Account.equity(
      name: "Shareholder's Dividend",
      company: company
    ),
    Account.equity(
      name: "Shareholder's Capital",
      company: company
    ),
  ];
}

// MARK: Income
List<Account> createIncome(Company company) {
  return [
    Account.parent(
      root: AccountRoot.income,
      company: company,
      name: "Direct Sales",
      children: [
        Account.income(
          company: company,
          name: "Sales Revenue",
        ),
        Account.income(
          company: company,
          name: "Sales Discount",
        ),
      ],
    ),
    Account.parent(
      root: AccountRoot.income,
      company: company,
      name: "Indirect Sales",
      children: [
        Account.income(
          company: company,
          name: "Interest Revenue",
        ),
        Account.income(
          company: company,
          name: "Indirect Sales Income",
        ),
      ],
    ),
  ];
}

// MARK: Expenses
List<Account> createExpenses(Company company) {
  return [
    Account.parent(
      root: AccountRoot.expense,
      name: "Cost of Goods Sold",
      type: AccountType.cogs,
      company: company,
      children: createCOGS(company),
    ),
    Account.parent(
      root: AccountRoot.expense,
      name: "Maintenance and Repairs",
      company: company,
      children: createMR(company),
    ),
    Account.parent(
      root: AccountRoot.expense,
      name: "Utilities",
      company: company,
      children: createUtilities(company),
    ),
    Account.parent(
      root: AccountRoot.expense,
      name: "Other Expenses",
      company: company,
      children: createOtherExpenses(company),
    ),
    Account.expense(
      name: "Tax",
      company: company,
      type: AccountType.depreciation,
    ),
    Account.expense(
      name: "Depreciations",
      company: company,
      type: AccountType.tax,
    ),
  ];
}

List<Account> createCOGS(Company company) {
  return [
    Account.expense(
      name: "Product Cost",
      type: AccountType.cogs,
      company: company
    ),
    Account.expense(
      name: "Material Cost",
      type: AccountType.cogs,
      company: company
    ),
    Account.expense(
      name: "Labor Cost",
      type: AccountType.cogs,
      company: company
    ),
    Account.expense(
      name: "Overhead Cost",
      type: AccountType.cogs,
      company: company
    )
  ];
}

List<Account> createMR(Company company) {
  return [
    Account.expense(
      name: "Maintenance",
      company: company,
    ),
    Account.expense(
      name: "Repair",
      company: company,
    )
  ];
}

List<Account> createUtilities(Company company) {
  return [
    Account.expense(
      name: "Travel",
      company: company,
    ),
    Account.expense(
      name: "Food",
      company: company,
    ),
    Account.expense(
      name: "Water",
      company: company,
    ),
    Account.expense(
      name: "Electricity",
      company: company,
    ),
  ];
}
List<Account> createOtherExpenses(Company company) {
  return [
    Account.expense(
      name: "Round off",
      company: company,
    ),
  ];
}
