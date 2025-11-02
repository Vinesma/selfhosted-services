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

    // This is the ID from Settings → Show advanced settings → Sync ID
    await api.downloadBudget(process.env.BUDGET_SYNC_ID);

    let accounts = await api.getAccounts();
    let balances = await Promise.all(
        accounts.map(async account => {
            const balance = await api.getAccountBalance(account.id);
            return {
                name: account.name,
                balance,
            };
        })
    );
    console.log(balances);

    await api.shutdown();
})();
