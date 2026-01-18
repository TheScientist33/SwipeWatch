'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "e51be1090ce698ca8b5ba8c66f4f7271",
".git/config": "d489cb02e13c87f70977e0f6e832ba0d",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "ea587b0fae70333bce92257152996e70",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "f9ea84dee3f99199163ce333226935ac",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "d76fe13ec7ce2e4e59923ee8014ccc5f",
".git/logs/refs/heads/master": "d76fe13ec7ce2e4e59923ee8014ccc5f",
".git/logs/refs/remotes/origin/gh-pages": "c466e7b5dad10b1fe7912b69fc2539b0",
".git/objects/08/248acd99e6104e141ec3a5f32ba481c284253f": "ebe2e232a49f4eb7843220059df834a7",
".git/objects/0a/92ed402a688cee6b72d75dcbe592411646a8a8": "a8de45797d61822447f97fbd51a06505",
".git/objects/0d/d8461ba727d440d7c87ed1a156d7c0dea65e0c": "d2ae2d9f74b93b8e1be3e7c73ff5723d",
".git/objects/11/2b755c7424dc644ab1b97dc9164bf817ebbc1f": "2e66799265448b16ffaccf952901046b",
".git/objects/1a/e5d3f46bfeae35ebcb6bfb8b2b575f22d1bca1": "1abebe46bb96474c861bc54ddaf811b9",
".git/objects/1d/468b85698a60041b450286f31b3264b3bbd6f7": "5c8c497111befde32ac151f14cf92f85",
".git/objects/1e/2e03cc6aea750b1b8dc54135d9d2685df371a7": "4c2b540884eff252eadf2a4132df3b8f",
".git/objects/20/f47184758d688692906682ecbde164ce3e35de": "c83d08d22b4c72fafd17d3a7f5b88527",
".git/objects/24/3f64cc8ccf58aafbceaa9e1ac87b972b122bcd": "20f55e4e29de925d2eb510713bd0a007",
".git/objects/27/cf0a507ea5ee074a034a65019bffb48dd45e3c": "f268ce164a40d757984dd75c5a344583",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/37/c10849a7c2d65118c7613cbb4d84ee6a87495e": "8c41b0bf1e3a28f3e1fd4b633fb6e719",
".git/objects/37/fb60cc0a382135c896e7087d998abb5720939d": "7706c998d15ed4f5e0844aee2e3f19a8",
".git/objects/37/fdca84c670b3bffef05f7492cd495283f1717e": "116db3cb24caee977fb10312c95710b2",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/51/7986bcd8c0987b8ec4904a6a605af4ff93034b": "c0241c0b45f587ef5af33a41e56317db",
".git/objects/55/43e97204baf5743c9030718c103f188ae52b94": "2c5126dbe6c277a2f2bfe2b4653a88cc",
".git/objects/55/9a104e94ce1621ee927456c073766ae1af564c": "9a7324f5ff172ae0d4291ef656bfb8d8",
".git/objects/56/d90d868b6c1401ef01f39b894a339be6187fa3": "70f846d58270dd10f9d53fd4b29803a2",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/62/e69316f78ffe9acf04772cffd5f072fb915471": "e1828086d66aa89ce1302e7bbde04501",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6c/4bb8ade8d47794395aba54f81f7a9ef6bdc867": "873cc38fcc443b332ebfce57f6f7dc76",
".git/objects/6d/6f22caa9479bb8b5e030212c306d54a0ed63a8": "e1630094c858104836130b6a697dbd40",
".git/objects/72/3d030bc89a4250e63d16b082affe1998618c3f": "e4299c419434fc51f64a5266659918fa",
".git/objects/7b/2269af29e540c7312a0295f939f018c252f44e": "3b4a61cc2bcbaa9ffc6608ccb00451b3",
".git/objects/7e/c1037f1468c45de1959cfb7ddb58893bfd69a7": "ac8fe548fd1b6c0d77a6356800016976",
".git/objects/80/c3b29f8e09e1fb9a47934de0d57fc54df89012": "bf5667dd595b08d3a31b02b19c84931a",
".git/objects/82/5dca8a8af386770bdfc0c0799833c8d93d2ec5": "2fb87714f4293497ccda2266c1b3ebbe",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8f/c8be62f202c40e7d3e2e16242fb065cfc4e1a7": "6fda1b80da67a8d96186cf8ab8b24087",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/9a/6c6ebe0d1602f086edcbf2d2dbb06f47196fc2": "0c3bf65c29cdb1680f8a3b7fb0a0b54b",
".git/objects/a4/19e7baf465d5306e3de8e26ef7fa69632a16d2": "91664548a1aa7a60b08988cdb68b3b32",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a7/c41c06fc45682228581dc2591545cf56f9e231": "10799a6bb1e3de1070b84eff5678fd3e",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/ac/3ad5e56f68b4015eff691a59d0c002bf782c79": "ce1c84a24e2c16dd05a0f127c53af697",
".git/objects/ae/a560a697194eaa1cfe85411bb9578bcdcbbe97": "8083a9951d7a869999abb228d06b6daf",
".git/objects/b1/e6642a84c1f7ff804483e82f2ee87b4231a10e": "fd4c0c0205077e72185287e85c6e6255",
".git/objects/b5/a7fb8dce8fa41218a6ef5f0e2249b2c3be6f3e": "85f810948a31f0c0c1292a3303a03c28",
".git/objects/b7/13892300f70a49c38470df06a08ac96d139f06": "bc28782058f731187f1881aba74f1b4c",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/d3/2862e3c1683e5795ddfc517ffaa76ea8bd58cc": "8b269eb335b34e6a1f886235d5eff368",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/57857ef05ae3ce6aed98a2cdb28a996c1e4fa7": "eccd75f82912a06bd50e15edcd046bee",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/d9/51bdbfbc797ce0619b6883fdbdef6e4762c437": "3e81778737c4ee9e936349a456a32fc7",
".git/objects/e7/b0e4104318d870b1da00983462f60ed63f80e0": "0fe78dfaaeab4b870f3aa069e8740757",
".git/objects/e8/d40c605a7056d3e3c7e1bc2377295e1c775c72": "b8af174255cca6ec166f0998a8466efe",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ee/8b72f51015219cecd5478a024d9511be2fc18d": "25d1fb7a0403804df9cd7dac17f434c5",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fb/14e8754b41a065158a7140f81aa62988cbbaea": "1963bfb6fbd1f4531bcc7c5c92127605",
".git/refs/heads/master": "69f35646802cc6722cad2b026c1bf9c9",
".git/refs/remotes/origin/gh-pages": "69f35646802cc6722cad2b026c1bf9c9",
"assets/api_key.env": "a9010822f3544dd0dca07f9b80f3f6a6",
"assets/AssetManifest.bin": "b6688cba569007608663fb31f366e404",
"assets/AssetManifest.bin.json": "7ca8990c54ee5ea3563469a2ea73228a",
"assets/AssetManifest.json": "10dc006340eb21ef2d9b2383cb7e5e0c",
"assets/assets/movies_dataset.json": "75b52fcff8bb7d836a54cff8d705aeea",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "c9c4dc17b9ce00ec8d18340005348973",
"assets/NOTICES": "9b9eaba16de0278cd176da653edd0088",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "8a7a407e9de21e6809e13a63d622bf46",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "48963c2246d70aa52c21997e1f8d5058",
"/": "48963c2246d70aa52c21997e1f8d5058",
"main.dart.js": "b0e5c77a33ce50707f3d5ecfd1b59a48",
"manifest.json": "a0e8ca5e0b1de723b0786e893aa65a96",
"version.json": "9851ba2575a5de4528557f64bdea2ac4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
