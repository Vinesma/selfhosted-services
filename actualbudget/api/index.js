require("dotenv").config({ quiet: true });
let api = require("@actual-app/api");

(async () => {
    await api.init({
        // Budget data will be cached locally here, in subdirectories for each file.
        dataDir: "./budget",
        serverURL: process.env.SERVER_URL,
        password: process.env.SERVER_PASSWORD,
        verbose: false,
    });

    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = String(now.getMonth() + 1).padStart(2, "0");
    const yearMonth = `${currentYear}-${currentMonth}`;

    const investmentsGroupName = "Investments and Savings";
    const investmentsCategoryName = "Contributions";

    // This is the ID from Settings → Show advanced settings → Sync ID
    await api.downloadBudget(process.env.BUDGET_SYNC_ID);

    let monthlyContribution = 0;
    let budgetCurrentMonth = await api.getBudgetMonth(yearMonth);
    let investmentsGroup = budgetCurrentMonth.categoryGroups.filter(
        group => group.name === investmentsGroupName,
    )?.[0];

    if (investmentsGroup) {
        let investmentsCategory = investmentsGroup.categories.filter(
            category => category.name === investmentsCategoryName,
        )?.[0];

        if (investmentsCategory) {
            monthlyContribution = investmentsCategory.balance;
        }
    }

    let accounts = await api.getAccounts();
    let balances = await Promise.all(
        accounts.map(async account => {
            const balance = await api.getAccountBalance(account.id);
            return {
                name: account.name,
                balance,
            };
        }),
    );

    balances.push({
        name: "monthlyContribution",
        balance: monthlyContribution,
    });

    console.log(JSON.stringify(balances));

    await api.shutdown();
})();
