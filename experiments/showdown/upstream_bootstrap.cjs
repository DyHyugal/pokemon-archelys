'use strict';
const path = require('node:path');
const root = process.env.ARCHELYS_SHOWDOWN_ROOT;
if (!root) throw new Error('Set ARCHELYS_SHOWDOWN_ROOT');
const {Dex} = require(path.join(root, 'dist/sim'));
global.Dex = Dex;
global.toID = Dex.toID;
