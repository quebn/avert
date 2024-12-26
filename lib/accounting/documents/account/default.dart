import "package:avert/core/documents/profile/document.dart";

import "document.dart";

Account createAssets(Profile profile) {
  return Account.group(
    root: AccountRoot.asset,
    profile: profile,
    name: "Assets",
    children: [
      Account.group(
        root: AccountRoot.asset,
        name: "Curent Assets",
        profile: profile,
        children: createCurrentAssets(profile),
      ),
      Account.group(
        root: AccountRoot.asset,
        name: "Non-current Assets",
        profile: profile,
        children: [
        ],
      ),
    ],
  );
}

Account createLiabilities(Profile profile) {
  return Account.group(
    root: AccountRoot.liability,
    profile: profile,
    name: "liabilities",
    children: [
      Account.group(
        root: AccountRoot.liability,
        name: "Curent liabilities",
        profile: profile,
        children: createCurrentAssets(profile),
      ),
      Account.group(
        root: AccountRoot.liability,
        name: "Non-current Liabilities",
        profile: profile,
        children: createNoncurrentLiabilities(profile),
      ),
    ]
  );
}

Account createEquity(Profile profile) {
  return Account.group(
    root: AccountRoot.equity,
    profile: profile,
    name: "Equity",
    children: [
      Account.equity(
        name: "Retained Earnings",
        profile: profile
      ),
      Account.equity(
        name: "Shareholder's Dividend",
        profile: profile
      ),
      Account.equity(
        name: "Shareholder's Capital",
        profile: profile
      ),
    ]
  );
}

Account createIncome(Profile profile) {
  return Account.group(
    root: AccountRoot.income,
    profile: profile,
    name: "Income",
    children: [
      Account.group(
        root: AccountRoot.income,
        profile: profile,
        name: "Direct Sales",
        children: [
          Account.income(
            profile: profile,
            name: "Sales Revenue",
          ),
          Account.income(
            profile: profile,
            name: "Sales Discount",
          ),
        ],
      ),
      Account.group(
        root: AccountRoot.income,
        profile: profile,
        name: "Indirect Sales",
        children: [
          Account.income(
            profile: profile,
            name: "Interest Revenue",
          ),
          Account.income(
            profile: profile,
            name: "Indirect Sales Income",
          ),
        ],
      ),
    ]
  );
}

Account createExpenses(Profile profile) {
  return Account.group(
    root: AccountRoot.expense,
    profile: profile,
    name: "Expenses",
    children: [
      Account.group(
        root: AccountRoot.expense,
        name: "Cost of Goods Sold",
        type: AccountType.cogs,
        profile: profile,
        children: createCOGS(profile),
      ),
      Account.group(
        root: AccountRoot.expense,
        name: "Maintenance and Repairs",
        profile: profile,
        children: createMR(profile),
      ),
      Account.group(
        root: AccountRoot.expense,
        name: "Utilities",
        profile: profile,
        children: createUtilities(profile),
      ),
      Account.group(
        root: AccountRoot.expense,
        name: "Other Expenses",
        profile: profile,
        children: createOtherExpenses(profile),
      ),
      Account.expense(
        name: "Tax",
        profile: profile,
        type: AccountType.depreciation,
      ),
      Account.expense(
        name: "Depreciations",
        profile: profile,
        type: AccountType.tax,
      ),
    ]
  );
}

// MARK: Assets
List<Account> createCurrentAssets(Profile profile) {
  return [
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Cash and cash equivalents",
      children: [
        Account.asset(
          profile: profile,
          name: "Bank",
          type: AccountType.bank,
        ),
        Account.asset(
          profile: profile,
          name: "Cash",
          type: AccountType.cash,
        ),
      ],
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Receivables",
      type: AccountType.receivable,
      children: [
        Account.asset(
          profile: profile,
          name: "Cash Advances to Suppliers",
          type: AccountType.receivable,
        ),
        Account.asset(
          profile: profile,
          name: "Accounts Receivable",
          type: AccountType.receivable,
        ),
      ]
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Stock",
      type: AccountType.inventory,
      children: [
        Account.asset(
          profile: profile,
          name: "Inventory",
          type: AccountType.inventory,
        ),
        Account.asset(
          profile: profile,
          name: "Merchandise",
          type: AccountType.inventory,
        ),
      ],
    ),
  ];
}

List<Account> createNoncurrentAssets(Profile profile) {
  return [
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Property Plant and Equipment",
      type: AccountType.fixedAsset,
      children: createPPEAssets (profile),
    ),
  ];
}

List<Account> createPPEAssets(Profile profile) {
  return [
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Land",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Land - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Land - Development",
          type: AccountType.fixedAsset,
        ),
      ]
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Machinery",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Equipment - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Equipment - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Tools",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Tools - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Tools - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Buildings",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Buildings - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Buildings - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Devices",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Devices - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Devices - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.group(
      root: AccountRoot.asset,
      profile: profile,
      name: "Vehicles",
      type: AccountType.fixedAsset,
      children: [
        Account.asset(
          profile: profile,
          name: "Vehicles - Cost",
          type: AccountType.fixedAsset,
        ),
        Account.asset(
          profile: profile,
          name: "Vehicles - Accum. Depreciation",
          type: AccountType.accumDepreciation,
        ),
      ],
    ),
    Account.asset(
      profile: profile,
      name: "Capital Work in Progress",
      type: AccountType.cwip,
    )
  ];
}

// MARK: Liabilities

List<Account> createCurrentLiabilities(Profile profile) {
  return [
    Account.group(
      root: AccountRoot.liability,
      profile: profile,
      name: "Payables",
      type: AccountType.payable,
      children: [
        Account.liability(
          profile: profile,
          name: "Cash Advances from Customers",
          type: AccountType.payable,
        ),
        Account.liability(
          profile: profile,
          name: "Accounts Payable",
          type: AccountType.payable,
        ),
        Account.liability(
          profile: profile,
          name: "Wages Payable",
          type: AccountType.payable,
        ),
        Account.liability(
          profile: profile,
          name: "Tax Payable",
          type: AccountType.payable,
        ),
      ]
    ),
  ];
}

List<Account> createNoncurrentLiabilities(Profile profile) {
  return [];
}

// MARK: Expenses

List<Account> createCOGS(Profile profile) {
  return [
    Account.expense(
      name: "Product Cost",
      type: AccountType.cogs,
      profile: profile
    ),
    Account.expense(
      name: "Material Cost",
      type: AccountType.cogs,
      profile: profile
    ),
    Account.expense(
      name: "Labor Cost",
      type: AccountType.cogs,
      profile: profile
    ),
    Account.expense(
      name: "Overhead Cost",
      type: AccountType.cogs,
      profile: profile
    )
  ];
}

List<Account> createMR(Profile profile) {
  return [
    Account.expense(
      name: "Maintenance",
      profile: profile,
    ),
    Account.expense(
      name: "Repair",
      profile: profile,
    )
  ];
}

List<Account> createUtilities(Profile profile) {
  return [
    Account.expense(
      name: "Travel",
      profile: profile,
    ),
    Account.expense(
      name: "Food",
      profile: profile,
    ),
    Account.expense(
      name: "Water",
      profile: profile,
    ),
    Account.expense(
      name: "Electricity",
      profile: profile,
    ),
  ];
}
List<Account> createOtherExpenses(Profile profile) {
  return [
    Account.expense(
      name: "Round off",
      profile: profile,
    ),
  ];
}
