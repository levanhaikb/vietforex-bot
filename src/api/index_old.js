
// Add to index.js
const VietForexOrchestrator = require('./orchestrator');
const orchestrator = new VietForexOrchestrator();

// Start orchestrator
orchestrator.init().then(() => {
    orchestrator.start();
});

