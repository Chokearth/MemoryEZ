const {assertFails, assertSucceeds} = require('@firebase/rules-unit-testing');
const {setup, teardown, Collection} = require('../helpers');

const mockData = {
    themes: new Collection({
        theme1: {
            name: 'theme1',
            colors: [
                255, 255, 255
            ],
            cardCount: 1,
            public: true,
            ownerId: 'user1',
            cards: new Collection({
                card1: {
                    front: 'front1',
                    back: 'back1',
                }
            }),
        },
        theme2: {
            name: 'theme2',
            colors: [
                255, 255, 255
            ],
            cardCount: 3,
            public: false,
            ownerId: 'user1',
            cards: new Collection({
                card1: {
                    front: 'front1',
                    back: 'back1',
                },
                card2: {
                    front: 'front2',
                    back: 'back2',
                },
                toDelete: {
                    front: 'frontToDelete',
                    back: 'backToDelete'
                }
            }),
        }
    }),
}

describe('Database rules', () => {
    let itEnv;
    let db1;
    let db2;

    beforeAll(async () => {
        const randomId = Math.random().toString(36).substring(2);
        itEnv = await setup(mockData, randomId);
        db1 = itEnv.fuser('user1', {email_verified: true});
        db2 = itEnv.fuser('user2', {email_verified: true});
    });

    afterAll(async () => {
        await teardown(itEnv);
    });

    it('deny if user not Authenticated', async () => {
        const db = itEnv.unauthenticatedContext().firestore();
        const ref = db.collection('a_table');
        await assertFails(ref.get());
    });

    describe('allow access to public if user Authenticated', () => {
        it('is owner', async () => {
            const ref = db1.collection('themes').doc('theme1');
            await assertSucceeds(ref.get());
        });
        it('is not owner', async () => {
            const ref = db2.collection('themes').doc('theme1');
            await assertSucceeds(ref.get());
        });
    });

    describe('access to private if user Authenticated', () => {
        it('is owner', async () => {
            const ref = db1.collection('themes').doc('theme2');
            await assertSucceeds(ref.get());
        });
        it('is not owner', async () => {
            const ref = db2.collection('themes').doc('theme2');
            await assertFails(ref.get());
        });
    });

    describe('list themes', () => {
        it('public', async () => {
            const ref = db2.collection('themes').where('public', '==', true);
            await assertSucceeds(ref.get());
        });
        it('private of owner', async () => {
            const ref = db1.collection('themes').where('ownerId', '==', 'user1');
            await assertSucceeds(ref.get());
        });
        it('private of not owner', async () => {
            const ref = db2.collection('themes').where('ownerId', '==', 'user1');
            await assertFails(ref.get());
        });
    });

    describe('list cards in theme', () => {
        it('is owner', async () => {
            const ref = db1.collection('themes').doc('theme2').collection('cards');
            await assertSucceeds(ref.get());
        });
        it('is not owner', async () => {
            const ref = db2.collection('themes').doc('theme2').collection('cards');
            await assertFails(ref.get());
        });
        it('is not owner but public', async () => {
            const ref = db2.collection('themes').doc('theme1').collection('cards');
            await assertSucceeds(ref.get());
        });
    });

    describe('create theme', () => {
        it('public', async () => {
            const ref = db1.collection('themes').doc('theme3');
            await assertSucceeds(ref.set({
                name: 'theme3',
                colors: [
                    255, 255, 255
                ],
                cardCount: 0,
                public: true,
                ownerId: 'user1',
            }));
        });
        it('private', async () => {
            const ref = db1.collection('themes').doc('theme4');
            await assertSucceeds(ref.set({
                name: 'theme4',
                colors: [
                    255, 255, 255
                ],
                cardCount: 0,
                public: false,
                ownerId: 'user1',
            }));
        });
        it('public to other user', async () => {
            const ref = db2.collection('themes').doc('theme5');
            await assertFails(ref.set({
                name: 'theme5',
                colors: [
                    255, 255, 255
                ],
                cardCount: 0,
                public: true,
                ownerId: 'user1',
            }));
        });
        it('can\'t create theme if email not verified', async () => {
            const db = itEnv.fuser('user3', {
                email_verified: false,
            });
            const ref = db.collection('themes').doc('theme6');
            await assertFails(ref.set({
                name: 'theme6',
                colors: [
                    255, 255, 255
                ],
                cardCount: 0,
                public: true,
                ownerId: 'user3',
            }));
        });
        it('can create theme if email verified', async () => {
            const db = itEnv.fuser('user4', {
                email_verified: true,
            });
            const ref = db.collection('themes').doc('theme6');
            await assertSucceeds(ref.set({
                name: 'theme7',
                colors: [
                    255, 255, 255
                ],
                cardCount: 0,
                public: true,
                ownerId: 'user4',
            }));
        });
    });

    describe('update theme', () => {
        it('owned theme', async () => {
            const ref = db1.collection('themes').doc('theme1');
            await assertSucceeds(ref.update({
                colors: [
                    0, 255, 255
                ],
            }));
        });
        it('not owned theme', async () => {
            const ref = db2.collection('themes').doc('theme1');
            await assertFails(ref.update({
                colors: [
                    0, 255, 255
                ],
            }));
        });
    });

    describe('create card', () => {
        it('owned theme', async () => {
            const ref = db1.collection('themes').doc('theme2').collection('cards').doc('card3');
            await assertSucceeds(ref.set({
                front: 'front',
                back: 'back',
            }));
        });
        it('not owned theme', async () => {
            const ref = db2.collection('themes').doc('theme2').collection('cards').doc('card4');
            await assertFails(ref.set({
                front: 'front',
                back: 'back',
            }));
        });
        it('public theme', async () => {
            const ref = db2.collection('themes').doc('theme1').collection('cards').doc('card2');
            await assertFails(ref.set({
                front: 'front',
                back: 'back',
            }));
        });
    });

    describe('update card', () => {
        it('owned theme', async () => {
            const ref = db1.collection('themes').doc('theme2').collection('cards').doc('card1');
            await assertSucceeds(ref.update({
                front: 'front',
                back: 'back',
            }));
        });
        it('not owned theme', async () => {
            const ref = db2.collection('themes').doc('theme2').collection('cards').doc('card2');
            await assertFails(ref.update({
                front: 'front',
                back: 'back',
            }));
        });
        it('public theme', async () => {
            const ref = db2.collection('themes').doc('theme1').collection('cards').doc('card1');
            await assertFails(ref.update({
                front: 'front',
                back: 'back',
            }));
        });
    });

    describe('forbid to change ownerId', () => {
        it('from owner', async () => {
            const ref = db1.collection('themes').doc('theme1');
            await assertFails(ref.update({
                ownerId: 'user2',
            }));
        });
        it('to owner', async () => {
            const ref = db2.collection('themes').doc('theme1');
            await assertFails(ref.update({
                ownerId: 'user2',
            }));
        });
    });

    describe('delete theme', () => {
        it('owned theme', async () => {
            const ref = db1.collection('themes').doc('theme1');
            await assertSucceeds(ref.delete());
        });
        it('not owned theme', async () => {
            const ref = db2.collection('themes').doc('theme1');
            await assertFails(ref.delete());
        });
    });

    describe('delete card', () => {
        it('owned theme', async () => {
            const ref = db1.collection('themes').doc('theme2').collection('cards').doc('toDelete');
            await assertSucceeds(ref.delete());
        });
        it('not owned theme', async () => {
            const ref = db2.collection('themes').doc('theme2').collection('cards').doc('card1');
            await assertFails(ref.delete());
        });
        it('public theme', async () => {
            const ref = db2.collection('themes').doc('theme1').collection('cards').doc('card1');
            await assertFails(ref.delete());
        });
    });

});