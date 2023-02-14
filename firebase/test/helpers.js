const {readFileSync} = require('fs');
const {initializeTestEnvironment} = require("@firebase/rules-unit-testing");

class Collection {
    constructor(data) {
        this.data = data;
    }
}

async function importCollection(db, collection) {
    for (const [key, value] of Object.entries(collection)) {
        if (value instanceof Collection) {
            await importCollection(db.collection(key), value.data);
        } else {
            const subCollection = Object.entries(value).filter(([key, value]) => value instanceof Collection).reduce((acc, [key, value]) => {
                acc[key] = value.data;
                return acc;
            }, {});

            for (const [skey, svalue] of Object.entries(subCollection)) {
                delete value[skey];
            }

            await db.doc(key).set(value);
            for (const [skey, svalue] of Object.entries(subCollection)) {
                await importCollection(db.doc(key).collection(skey), svalue);
            }
        }
    }
}

module.exports.setup = async (data, testId) => {
    const projectId = `memory-ez`//-test-${testId}`;
    const env =  await initializeTestEnvironment({
        projectId,
        firestore: {
            rules: readFileSync('firestore.rules', 'utf8'),
            host: '127.0.0.1',
            port: 8080,
        }
    });

    await env.withSecurityRulesDisabled(async (ctx) => {
        const db = ctx.firestore();
        await importCollection(db, data);
    });

    env.fuser = (uid, tokenOption = undefined) => env.authenticatedContext(uid, tokenOption).firestore();

    return env;
};

module.exports.teardown = async (testEnv) => {
    await testEnv.clearFirestore();
};

module.exports.Collection = Collection;