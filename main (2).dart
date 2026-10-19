import 'dart:math';
import 'package:flutter/material.dart';
// ============================ UTIL ============================
String rp(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}Rp$b';
}
String two(int n) => n.toString().padLeft(2, '0');
String jam(DateTime d) => '${two(d.hour)}:${two(d.minute)}';
String tgl(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';
const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
const cats = ['Roti', 'Pastry', 'Kue', 'Minuman'];
const emojis = [
  '🍞',
  '🥖',
  '🥐',
  '🥨',
  '🍩',
  '🍰',
  '🧁',
  '🍫',
  '☕',
  '🥤',
  '🧀',
  '🌭',
];
Color statusColor(String s) => s == 'Tersedia'
    ? Colors.green
    : s == 'Habis'
    ? Colors.red
    : Colors.orange;
// ============================ MODEL & STORE ============================
class AppUser {
  String name, username, password, role;
  bool active;
  AppUser(
    this.name,
    this.username,
    this.password,
    this.role, [
    this.active = true,
  ]);
}
class Product {
  String id, name, category, emoji, desc;
  int price, stock, minStock;
  Product(
    this.id,
    this.name,
    this.category,
    this.emoji,
    this.price,
    this.stock,
    this.minStock, [
    this.desc = '',
  ]);
  String get status => stock == 0
      ? 'Habis'
      : stock <= minStock
      ? 'Stok Menipis'
      : 'Tersedia';
}
class Promo {
  String id, productId, type; // 'persen' | 'potongan'
  int value;
  DateTime start, end;
  bool enabled;
  Promo(
    this.id,
    this.productId,
    this.type,
    this.value,
    this.start,
    this.end, [
    this.enabled = true,
  ]);
  String get status {
    final t = dateOnly(DateTime.now());
    if (!enabled) return 'Nonaktif';
    if (t.isBefore(start)) return 'Belum Aktif';
    if (t.isAfter(end)) return 'Berakhir';
    return 'Aktif';
  }
  String get label =>
      type == 'persen' ? 'Diskon $value%' : 'Potongan ${rp(value)}';
  String get periode => '${tgl(start)} - ${tgl(end)}';
  int apply(int price) =>
      max(0, type == 'persen' ? price - price * value ~/ 100 : price - value);
}
Color promoColor(String s) => s == 'Aktif'
    ? Colors.green
    : s == 'Belum Aktif'
    ? Colors.blue
    : Colors.grey;
class SaleLine {
  final String name;
  final bool promo;
  final int qty, price;
  SaleLine(this.name, this.qty, this.price, [this.promo = false]);
}
class Sale {
  final String id, cashier;
  final DateTime time;
  final List<SaleLine> lines;
  final int paid;
  Sale(this.id, this.time, this.cashier, this.lines, this.paid);
  int get total => lines.fold(0, (s, l) => s + l.qty * l.price);
  int get items => lines.fold(0, (s, l) => s + l.qty);
}
class Store extends ChangeNotifier {
  final users = <AppUser>[
    AppUser('Budi Pengelola', 'admin', 'admin123', 'Admin'),
    AppUser('Sari Dewi', 'kasir', 'kasir123', 'Kasir'),
  ];
  AppUser? me;
  final products = <Product>[
    Product(
      'P01',
      'Roti Tawar',
      'Roti',
      '🍞',
      18000,
      14,
      5,
      'Roti tawar lembut, 1 loaf',
    ),
    Product(
      'P02',
      'Roti Cokelat',
      'Roti',
      '🥖',
      10000,
      22,
      8,
      'Isian cokelat meleleh',
    ),
    Product(
      'P03',
      'Roti Keju',
      'Roti',
      '🧀',
      8000,
      3,
      8,
      'Taburan keju cheddar',
    ),
    Product(
      'P04',
      'Roti Sosis',
      'Roti',
      '🌭',
      9000,
      16,
      6,
      'Sosis sapi panggang',
    ),
    Product(
      'P05',
      'Croissant',
      'Pastry',
      '🥐',
      15000,
      10,
      5,
      'Butter croissant renyah',
    ),
    Product(
      'P06',
      'Donat Gula',
      'Pastry',
      '🍩',
      6000,
      30,
      10,
      'Donat empuk gula halus',
    ),
    Product(
      'P07',
      'Pretzel',
      'Pastry',
      '🥨',
      12000,
      0,
      4,
      'Pretzel garam laut',
    ),
    Product(
      'P08',
      'Brownies',
      'Kue',
      '🍫',
      22000,
      12,
      5,
      'Brownies panggang fudgy',
    ),
    Product(
      'P09',
      'Cheesecake Slice',
      'Kue',
      '🍰',
      28000,
      7,
      4,
      'Cheesecake New York',
    ),
    Product(
      'P10',
      'Cupcake Vanila',
      'Kue',
      '🧁',
      12000,
      18,
      6,
      'Cupcake dengan buttercream',
    ),
    Product(
      'P11',
      'Kopi Susu',
      'Minuman',
      '☕',
      18000,
      40,
      10,
      'Kopi susu gula aren',
    ),
    Product(
      'P12',
      'Teh Lemon',
      'Minuman',
      '🥤',
      12000,
      4,
      10,
      'Teh dingin segar',
    ),
  ];
  final cart = <String, int>{};
  final promos = <Promo>[];
  final sales = <Sale>[];
  int _seq = 1000;
  Store() {
    final r = Random(7);
    final now = DateTime.now();
    final t0 = dateOnly(now);
    Duration dd(int n) => Duration(days: n);
    promos.addAll([
      Promo('PR1', 'P02', 'persen', 20, t0.subtract(dd(1)), t0.add(dd(5))),
      Promo('PR2', 'P05', 'potongan', 3000, t0.subtract(dd(2)), t0.add(dd(3))),
      Promo('PR3', 'P08', 'persen', 10, t0.add(dd(3)), t0.add(dd(8))),
      Promo('PR4', 'P06', 'persen', 15, t0.subtract(dd(9)), t0.subtract(dd(3))),
    ]);
    // Data contoh penjualan 30 hari terakhir (untuk demo grafik).
    final kasir = ['Sari Dewi', 'Rina Putri'];
    for (var d = 29; d >= 0; d--) {
      final n = d == 0 ? 10 : 8 + r.nextInt(10);
      for (var i = 0; i < n; i++) {
        var t = dateOnly(now)
            .subtract(Duration(days: d))
            .add(Duration(hours: 7 + r.nextInt(13), minutes: r.nextInt(60)));
        if (t.isAfter(now)) t = now.subtract(Duration(minutes: r.nextInt(240)));
        final lines = [
          for (final p in (List.of(
            products,
          )..shuffle(r)).take(1 + r.nextInt(3)))
            SaleLine(p.name, 1 + r.nextInt(3), p.price),
        ];
        final total = lines.fold(0, (s, l) => s + l.qty * l.price);
        sales.add(
          Sale(
            'TRX${_seq++}',
            t,
            kasir[r.nextInt(2)],
            lines,
            (total / 5000).ceil() * 5000,
          ),
        );
      }
    }
    sales.sort((a, b) => b.time.compareTo(a.time));
  }

  // ---- Akun
  String? login(String u, String p) {
    final m = users.where((x) => x.username == u.trim() && x.password == p);
    if (m.isEmpty) return 'Username atau password salah';
    if (!m.first.active) return 'Akun dinonaktifkan oleh admin';
    me = m.first;
    notifyListeners();
    return null;
  }

  void logout() {
    me = null;
    cart.clear();
    notifyListeners();
  }

  bool get isAdmin => me?.role == 'Admin';

  // ---- Produk & stok (sederhana: satu angka stok per produk)
  Product byId(String id) => products.firstWhere((p) => p.id == id);
  List<Product> get lowStock =>
      products.where((p) => p.status != 'Tersedia').toList();

  void addProduct(Product p) {
    if (!isAdmin) throw StateError('Hanya Admin yang dapat mengelola produk.');
    products.add(p);
    notifyListeners();
  }

  void addStock(Product p, int qty) {
    if (!isAdmin) throw StateError('Hanya Admin yang dapat mengubah stok.');
    p.stock += qty;
    notifyListeners();
  }

  void deleteProduct(Product p) {
    if (!isAdmin) throw StateError('Hanya Admin yang dapat mengelola produk.');
    cart.remove(p.id);
    promos.removeWhere((x) => x.productId == p.id);
    products.remove(p);
    notifyListeners();
  }

  void touch() => notifyListeners();

  // ---- Promo
  Promo? promoOf(Product p) {
    for (final x in promos) {
      if (x.productId == p.id && x.status == 'Aktif') return x;
    }
    return null;
  }

  int priceOf(Product p) => promoOf(p)?.apply(p.price) ?? p.price;
  List<Promo> get activePromos =>
      promos.where((x) => x.status == 'Aktif').toList();

  // ---- Keranjang & transaksi
  int get cartCount => cart.values.fold(0, (a, b) => a + b);
  int get cartTotal =>
      cart.entries.fold(0, (s, e) => s + priceOf(byId(e.key)) * e.value);

  void add(Product p) {
    final q = cart[p.id] ?? 0;
    if (q >= p.stock) return;
    cart[p.id] = q + 1;
    notifyListeners();
  }

  void dec(Product p) {
    final q = (cart[p.id] ?? 0) - 1;
    q <= 0 ? cart.remove(p.id) : cart[p.id] = q;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  Sale checkout(int paid) {
    if (cart.isEmpty) throw StateError('Keranjang kosong.');
    for (final e in cart.entries) {
      final p = byId(e.key);
      if (e.value <= 0 || e.value > p.stock) {
        throw StateError('Stok ${p.name} tidak mencukupi. Transaksi dibatalkan.');
      }
    }
    final lines = cart.entries.map((e) {
      final p = byId(e.key);
      final line = SaleLine(p.name, e.value, priceOf(p), promoOf(p) != null);
      p.stock -= e.value;
      return line;
    }).toList();
    final s = Sale('TRX${_seq++}', DateTime.now(), me!.name, lines, paid);
    sales.insert(0, s);
    cart.clear();
    notifyListeners();
    return s;
  }

  List<Sale> between(DateTime from, DateTime to, {bool mine = false}) => sales
      .where(
        (s) =>
            !s.time.isBefore(from) &&
            s.time.isBefore(to.add(const Duration(days: 1))) &&
            (!mine || s.cashier == me!.name),
      )
      .toList();
}
final store = Store();
// ============================ APP ============================
void main() => runApp(const BakeryApp());
class BakeryApp extends StatelessWidget {
  const BakeryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BakeryPOS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFFB5651D),
      scaffoldBackgroundColor: const Color(0xFFFFF8F0),
    ),
    home: ListenableBuilder(
      listenable: store,
      builder: (_, _) => store.me == null
          ? const LoginPage()
          : Shell(key: ValueKey(store.me!.username)),
    ),
  );
}
// ============================ LOGIN ============================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final u = TextEditingController(), p = TextEditingController();
  bool hide = true;
  String? err;
  void submit() => setState(() => err = store.login(u.text, p.text));
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, const Color(0xFFF2C18D)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🥐', style: TextStyle(fontSize: 56)),
                      Text(
                        'BakeryPOS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      const Text('Aplikasi Kasir Toko Roti'),
                      const SizedBox(height: 24),
                      TextField(
                        controller: u,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: p,
                        obscureText: hide,
                        onSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hide ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() => hide = !hide),
                          ),
                        ),
                      ),
                      if (err != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            err!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 18),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: submit,
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ============================ SHELL ============================
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}
class _ShellState extends State<Shell> {
  int i = 0;
  void go(int v) => setState(() => i = v);
  @override
  Widget build(BuildContext context) {
    final admin = store.isAdmin;
    final pages = admin
        ? [
            DashboardPage(go: go),
            const ProdukPage(),
            const PromoPage(),
            const RekapPage(mine: false),
            const ProfilPage(),
          ]
        : [
            DashboardPage(go: go),
            const TransaksiPage(),
            const RekapPage(mine: true),
            const ProfilPage(),
          ];
    final dests = admin
        ? [
            (Icons.dashboard, 'Dashboard'),
            (Icons.bakery_dining, 'Produk & Stok'),
            (Icons.local_offer, 'Atur Promo'),
            (Icons.bar_chart, 'Rekap'),
            (Icons.account_circle, 'Profil'),
          ]
        : [
            (Icons.dashboard, 'Dashboard'),
            (Icons.point_of_sale, 'Transaksi'),
            (Icons.history, 'Riwayat'),
            (Icons.account_circle, 'Profil'),
          ];
    final wide = MediaQuery.of(context).size.width >= 800;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: Text(
          '🥐 BakeryPOS  •  ${dests[i].$2}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Chip(
              label: Text(
                '${store.me!.name} (${store.me!.role})',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: i,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in dests)
                  NavigationRailDestination(
                    icon: Icon(d.$1),
                    label: Text(d.$2),
                  ),
              ],
            ),
          Expanded(child: pages[i]),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: i,
              onDestinationSelected: go,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final d in dests)
                  NavigationDestination(
                    icon: Icon(d.$1),
                    label: d.$2 == 'Atur Promo' ? 'Promo' : d.$2,
                  ),
              ],
            ),
    );
  }
}
// ============================ WIDGET BANTU ============================
Widget statCard(String t, String v, IconData i, Color c) => SizedBox(
  width: 210,
  child: Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: c.withValues(alpha: .15),
            child: Icon(i, color: c),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontSize: 12)),
                Text(
                  v,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
Widget sectionCard(String title, Widget child) => Card(
  color: Colors.white,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  ),
);
class BarChart extends StatelessWidget {
  final List<String> labels;
  final List<int> values;
  const BarChart(this.labels, this.values, {super.key});
  @override
  Widget build(BuildContext context) {
    final mx = max(values.fold(0, max), 1);
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              SizedBox(
                width: 46,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${values[i] ~/ 1000}k',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 110 * values[i] / mx,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: i == values.length - 1
                            ? cs.primary
                            : cs.primary.withValues(alpha: .45),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(labels[i], style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
Widget saleTile(Sale s, {bool showCashier = true}) => ExpansionTile(
  tilePadding: EdgeInsets.zero,
  title: Text('${s.id} • ${tgl(s.time)} ${jam(s.time)}'),
  subtitle: Text('${s.items} item${showCashier ? ' • ${s.cashier}' : ''}'),
  trailing: Text(
    rp(s.total),
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  children: [
    for (final l in s.lines)
      ListTile(
        dense: true,
        title: Text('${l.qty}x ${l.name}'),
        trailing: Text(rp(l.qty * l.price)),
      ),
    ListTile(
      dense: true,
      title: Text('Bayar ${rp(s.paid)}  •  Kembali ${rp(s.paid - s.total)}'),
    ),
  ],
);
// ============================ DASHBOARD ============================
class DashboardPage extends StatelessWidget {
  final void Function(int) go;
  const DashboardPage({super.key, required this.go});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final admin = store.isAdmin;
        final today = dateOnly(DateTime.now());
        final list = store.between(today, today, mine: !admin);
        final omzet = list.fold(0, (s, e) => s + e.total);
        final low = store.lowStock;
        final days = [
          for (var d = 6; d >= 0; d--) today.subtract(Duration(days: d)),
        ];
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              'Halo, ${store.me!.name} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              admin
                  ? 'Ringkasan toko hari ini'
                  : 'Semangat melayani pelanggan hari ini!',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: admin
                  ? [
                      statCard(
                        'Penjualan Hari Ini',
                        rp(omzet),
                        Icons.attach_money,
                        Colors.green,
                      ),
                      statCard(
                        'Transaksi Hari Ini',
                        '${list.length}',
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                      statCard(
                        'Stok Perlu Perhatian',
                        '${low.length}',
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      statCard(
                        'Promo Aktif',
                        '${store.activePromos.length}',
                        Icons.local_offer,
                        Colors.pink,
                      ),
                    ]
                  : [
                      statCard(
                        'Transaksi Saya Hari Ini',
                        '${list.length}',
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                      statCard(
                        'Total Penjualan Saya',
                        rp(omzet),
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ],
            ),
            const SizedBox(height: 8),
            if (!admin) ...promoReminders(go),
            if (!admin)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Mulai Transaksi Kasir'),
                onPressed: () => go(1),
              ),
            if (admin) ...[
              sectionCard(
                'Penjualan 7 Hari',
                BarChart(
                  [for (final d in days) hari[d.weekday - 1]],
                  [
                    for (final d in days)
                      store.between(d, d).fold(0, (s, e) => s + e.total),
                  ],
                ),
              ),
              sectionCard(
                'Produk Perlu Restok',
                Column(
                  children: [
                    if (low.isEmpty) const Text('Semua stok aman 👍'),
                    for (final p in low.take(6))
                      ListTile(
                        dense: true,
                        leading: Text(
                          p.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(p.name),
                        subtitle: Text(
                          'Sisa ${p.stock} pcs (min ${p.minStock})',
                        ),
                        trailing: Chip(
                          label: Text(
                            p.status,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: statusColor(
                            p.status,
                          ).withValues(alpha: .2),
                        ),
                      ),
                    TextButton(
                      onPressed: () => go(1),
                      child: const Text('Kelola produk & stok'),
                    ),
                  ],
                ),
              ),
            ],
            sectionCard(
              'Transaksi Terbaru',
              Column(
                children: [
                  if (list.isEmpty) const Text('Belum ada transaksi.'),
                  for (final s in list.take(6)) saleTile(s, showCashier: admin),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
// ============================ TRANSAKSI ============================
class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});
  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}
class _TransaksiPageState extends State<TransaksiPage> {
  String cat = 'Semua', q = '';
  @override
  Widget build(BuildContext context) {
    if (store.isAdmin) {
      return const Center(child: Text('Halaman transaksi khusus role Kasir.'));
    }
    final wide = MediaQuery.of(context).size.width >= 800;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = store.products
            .where(
              (p) =>
                  (cat == 'Semua' || p.category == cat) &&
                  p.name.toLowerCase().contains(q.toLowerCase()),
            )
            .toList();
        final catalog = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari produk...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => q = v),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final c in ['Semua', ...cats])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: cat == c,
                        onSelected: (_) => setState(() => cat = c),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) => ProductCard(list[i]),
              ),
            ),
            if (!wide && store.cartCount > 0)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.shopping_basket),
                    label: Text(
                      'Keranjang (${store.cartCount}) • ${rp(store.cartTotal)}',
                    ),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => SizedBox(
                        height: MediaQuery.of(context).size.height * .8,
                        child: const CartPanel(inSheet: true),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        return wide
            ? Row(
                children: [
                  Expanded(child: catalog),
                  const SizedBox(width: 380, child: CartPanel()),
                ],
              )
            : catalog;
      },
    );
  }
}
class ProductCard extends StatelessWidget {
  final Product p;
  const ProductCard(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final available = p.stock;
    final habis = available == 0;
    final inCart = store.cart[p.id] ?? 0;
    return Opacity(
      opacity: habis ? .45 : 1,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: inCart > 0
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: habis ? null : () => store.add(p),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (store.promoOf(p) != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PROMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    rp(p.price),
                    style: const TextStyle(
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                Text(
                  rp(store.priceOf(p)),
                  style: TextStyle(
                    color: store.promoOf(p) != null
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(p.status).withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    habis ? 'Habis / kedaluwarsa' : 'Stok $available',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CartPanel extends StatelessWidget {
  final bool inSheet;
  const CartPanel({super.key, this.inSheet = false});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.cart.entries.toList();
        return Material(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Keranjang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: items.isEmpty
                    ? null
                    : TextButton(
                        onPressed: store.clearCart,
                        child: const Text('Kosongkan'),
                      ),
              ),
              const Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada item.\nKetuk produk untuk menambah.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        children: [
                          for (final e in items)
                            Builder(
                              builder: (_) {
                                final p = store.byId(e.key);
                                return ListTile(
                                  leading: Text(
                                    p.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  title: Text(p.name),
                                  subtitle: Text(
                                    '${store.promoOf(p) != null ? '🏷️ PROMO ' : ''}${rp(store.priceOf(p))} • ${rp(store.priceOf(p) * e.value)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () => store.dec(p),
                                      ),
                                      Text(
                                        '${e.value}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed:
                                            e.value >= p.stock
                                            ? null
                                            : () => store.add(p),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16)),
                        Text(
                          rp(store.cartTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.payments),
                      label: const Text('Bayar'),
                      onPressed: items.isEmpty
                          ? null
                          : () async {
                              final root = Navigator.of(
                                context,
                                rootNavigator: true,
                              );
                              final sale = await showDialog<Sale>(
                                context: context,
                                builder: (_) => const PayDialog(),
                              );
                              if (sale == null) return;
                              if (inSheet && context.mounted) {
                                Navigator.of(context).pop();
                              }
                              showDialog(
                                context: root.context,
                                builder: (_) => ReceiptDialog(sale),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class PayDialog extends StatefulWidget {
  const PayDialog({super.key});
  @override
  State<PayDialog> createState() => _PayDialogState();
}
class _PayDialogState extends State<PayDialog> {
  final ctrl = TextEditingController();
  String? error;
  int get total => store.cartTotal;
  int get paid => int.tryParse(ctrl.text) ?? 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pembayaran'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in store.cart.entries)
                Text(
                  '${e.value}x ${store.byId(e.key).name}  —  ${rp(store.priceOf(store.byId(e.key)) * e.value)}',
                ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rp(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Uang diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Uang pas'),
                    onPressed: () => setState(() => ctrl.text = '$total'),
                  ),
                  for (final v in [20000, 50000, 100000])
                    ActionChip(
                      label: Text(rp(v)),
                      onPressed: () => setState(() => ctrl.text = '$v'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian'),
                  Text(
                    paid >= total ? rp(paid - total) : 'Uang kurang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: paid >= total ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: paid >= total
              ? () {
                  try {
                    Navigator.pop(context, store.checkout(paid));
                  } on StateError catch (e) {
                    setState(() => error = e.message);
                  }
                }
              : null,
          child: const Text('Proses Pembayaran'),
        ),
      ],
    );
  }
}
class ReceiptDialog extends StatelessWidget {
  final Sale s;
  const ReceiptDialog(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13);
    Widget r(String a, String b, [TextStyle? st]) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: st ?? mono),
        Text(b, style: st ?? mono),
      ],
    );
    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: const Text('Transaksi Berhasil', textAlign: TextAlign.center),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BAKERYPOS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${s.id} • ${tgl(s.time)} ${jam(s.time)}', style: mono),
            Text('Kasir: ${s.cashier}', style: mono),
            const Divider(),
            for (final l in s.lines)
              r(
                '${l.qty}x ${l.name}${l.promo ? ' (PROMO)' : ''}',
                rp(l.qty * l.price),
              ),
            const Divider(),
            r('TOTAL', rp(s.total), mono.copyWith(fontWeight: FontWeight.bold)),
            r('Bayar', rp(s.paid)),
            r('Kembali', rp(s.paid - s.total)),
            const Divider(),
            const Text(
              'Stok produk telah diperbarui.\nTerima kasih! 🥐',
              style: mono,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
// ============================ PRODUK & STOK ============================
Future<int?> askNumber(
  BuildContext c,
  String title, {
  String label = 'Jumlah',
}) {
  final ctrl = TextEditingController();
  return showDialog<int>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, int.tryParse(ctrl.text)),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}
class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});
  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  String q = '', st = 'Semua';
  @override
  Widget build(BuildContext context) {
    if (!store.isAdmin) {
      return const Center(child: Text('Manajemen produk hanya untuk Admin.'));
    }
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final ps =
            store.products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(q.toLowerCase()) &&
                      (st == 'Semua' || p.status == st),
                )
                .toList()
              ..sort(
                (a, b) =>
                    (a.stock - a.minStock).compareTo(b.stock - b.minStock),
              );
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductForm()),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari produk...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => q = v),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in ['Semua', 'Tersedia', 'Stok Menipis', 'Habis'])
                    ChoiceChip(
                      label: Text(s),
                      selected: st == s,
                      onSelected: (_) => setState(() => st = s),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Card(
                color: Color(0xFFFFF3E0),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    'Stok berkurang otomatis setiap transaksi. Tekan + untuk menambah stok setelah produksi.',
                  ),
                ),
              ),
              if (ps.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Produk tidak ditemukan')),
                ),
              for (final p in ps)
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 34)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${p.category} • ${rp(store.priceOf(p))}${store.promoOf(p) != null ? '  (PROMO)' : ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: (p.stock / max(p.minStock * 3, 1)).clamp(
                                  0.0,
                                  1.0,
                                ),
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(6),
                                color: statusColor(p.status),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok ${p.stock} (min ${p.minStock}) • Terjual hari ini: ${soldToday(p)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            p.status,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: statusColor(
                            p.status,
                          ).withValues(alpha: .18),
                        ),
                        IconButton(
                          tooltip: 'Tambah stok',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () async {
                            final n = await askNumber(
                              context,
                              'Tambah stok ${p.name}',
                              label: 'Jumlah tambahan',
                            );
                            if (n != null && n > 0) store.addStock(p, n);
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductForm(product: p),
                                ),
                              );
                            }
                            if (v == 'del') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus produk?'),
                                  content: Text(
                                    '${p.name} akan dihapus dari daftar. Riwayat penjualan tetap tersimpan.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) store.deleteProduct(p);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit produk'),
                            ),
                            PopupMenuItem(value: 'del', child: Text('Hapus')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.product?.name);
  late final price = TextEditingController(
    text: widget.product?.price.toString(),
  );
  late final stock = TextEditingController(
    text: (widget.product?.stock ?? 0).toString(),
  );
  late final minStock = TextEditingController(
    text: (widget.product?.minStock ?? 5).toString(),
  );
  late final desc = TextEditingController(text: widget.product?.desc);
  late String cat = widget.product?.category ?? cats.first;
  late String emoji = widget.product?.emoji ?? emojis.first;

  String? req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;
  String? num_(String? v) {
    final n = int.tryParse(v ?? '');
    return (n == null || n < 0) ? 'Isi dengan angka 0 atau lebih' : null;
  }

  void save() {
    if (!key.currentState!.validate()) return;
    final p = widget.product;
    if (p == null) {
      store.addProduct(
        Product(
          'N${DateTime.now().microsecondsSinceEpoch}',
          name.text.trim(),
          cat,
          emoji,
          int.parse(price.text),
          int.parse(stock.text),
          int.parse(minStock.text),
          desc.text.trim(),
        ),
      );
    } else {
      p
        ..name = name.text.trim()
        ..category = cat
        ..emoji = emoji
        ..price = int.parse(price.text)
        ..stock = int.parse(stock.text)
        ..minStock = int.parse(minStock.text)
        ..desc = desc.text.trim();
      store.touch();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
    minStock.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: key,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Ikon produk (pengganti foto)'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in emojis)
                      ChoiceChip(
                        label: Text(e, style: const TextStyle(fontSize: 22)),
                        selected: emoji == e,
                        onSelected: (_) => setState(() => emoji = e),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: name,
                  validator: req,
                  decoration: const InputDecoration(
                    labelText: 'Nama produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: cat,
                  items: [
                    for (final c in cats)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => cat = v!),
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: price,
                  validator: num_,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stock,
                        validator: num_,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok saat ini',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: minStock,
                        validator: num_,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Batas stok menipis',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi produk (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: save,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ============================ REKAP / RIWAYAT ============================
class RekapPage extends StatefulWidget {
  final bool mine;
  const RekapPage({super.key, required this.mine});
  @override
  State<RekapPage> createState() => _RekapPageState();
}
class _RekapPageState extends State<RekapPage> {
  int period = 0;
  DateTimeRange? custom;
  static const names = [
    'Hari ini',
    'Minggu ini',
    'Bulan ini',
    'Periode tertentu',
  ];
  (DateTime, DateTime) get range {
    final t = dateOnly(DateTime.now());
    switch (period) {
      case 1:
        return (t.subtract(Duration(days: t.weekday - 1)), t);
      case 2:
        return (DateTime(t.year, t.month, 1), t);
      case 3:
        return custom == null
            ? (t, t)
            : (dateOnly(custom!.start), dateOnly(custom!.end));
      default:
        return (t, t);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final (from, to) = range;
        final list = store.between(from, to, mine: widget.mine);
        final total = list.fold(0, (s, e) => s + e.total);
        final items = list.fold(0, (s, e) => s + e.items);
        final nDays = to.difference(from).inDays + 1;
        final days = [
          for (var i = 0; i < nDays; i++) from.add(Duration(days: i)),
        ];
        final perDay = [
          for (final d in days)
            list
                .where((s) => sameDay(s.time, d))
                .fold(0, (a, s) => a + s.total),
        ];
        final prod = <String, List<int>>{};
        for (final s in list) {
          for (final l in s.lines) {
            final e = prod.putIfAbsent(l.name, () => [0, 0]);
            e[0] += l.qty;
            e[1] += l.qty * l.price;
          }
        }
        final pl = prod.entries.toList()
          ..sort((a, b) => b.value[0].compareTo(a.value[0]));
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < 4; i++)
                  ChoiceChip(
                    label: Text(
                      i == 3 && custom != null
                          ? '${tgl(custom!.start)} - ${tgl(custom!.end)}'
                          : names[i],
                    ),
                    selected: period == i,
                    onSelected: (_) async {
                      if (i == 3) {
                        final r = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );
                        if (r == null) return;
                        custom = r;
                      }
                      setState(() => period = i);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${tgl(from)} s/d ${tgl(to)}${widget.mine ? '  •  transaksi saya' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                statCard(
                  widget.mine ? 'Total Penjualan Saya' : 'Total Penjualan',
                  rp(total),
                  Icons.attach_money,
                  Colors.green,
                ),
                statCard(
                  'Jumlah Transaksi',
                  '${list.length}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
                statCard(
                  'Produk Terjual',
                  '$items pcs',
                  Icons.bakery_dining,
                  Colors.orange,
                ),
                statCard(
                  'Rata-rata/Transaksi',
                  rp(list.isEmpty ? 0 : total ~/ list.length),
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
            if (nDays > 1)
              sectionCard(
                'Penjualan per Hari',
                BarChart([for (final d in days) '${d.day}/${d.month}'], perDay),
              ),
            sectionCard(
              'Produk Terjual',
              Column(
                children: [
                  if (pl.isEmpty) const Text('Belum ada data.'),
                  for (var i = 0; i < pl.length && i < 8; i++)
                    ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${i + 1}'),
                      ),
                      title: Text(pl[i].key),
                      subtitle: Text(rp(pl[i].value[1])),
                      trailing: Text(
                        '${pl[i].value[0]} pcs',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            sectionCard(
              'Detail Transaksi (${list.length})',
              Column(
                children: [
                  if (list.isEmpty)
                    const Text('Tidak ada transaksi pada periode ini.'),
                  for (final s in list.take(50))
                    saleTile(s, showCashier: !widget.mine),
                  if (list.length > 50)
                    Text(
                      'Menampilkan 50 transaksi terbaru dari ${list.length}.',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
// ============================ PROFIL ============================
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final me = store.me!;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: Text(
                        me.name[0],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      me.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@${me.username}'),
                    const SizedBox(height: 6),
                    Chip(label: Text(me.role)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.key),
                          label: const Text('Ubah Password'),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const PasswordDialog(),
                          ),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Keluar dari aplikasi?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) store.logout();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (store.isAdmin)
              sectionCard(
                'Kelola Akun Pengguna',
                Column(
                  children: [
                    for (final u in store.users)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(u.name[0])),
                        title: Text(u.name),
                        subtitle: Text('@${u.username} • ${u.role}'),
                        trailing: u == me
                            ? const Text('Anda')
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: u.active,
                                    onChanged: (v) {
                                      u.active = v;
                                      store.touch();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      store.users.remove(u);
                                      store.touch();
                                    },
                                  ),
                                ],
                              ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Tambah Pengguna'),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const UserDialog(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});
  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}
class _PasswordDialogState extends State<PasswordDialog> {
  final o = TextEditingController(),
      n = TextEditingController(),
      c = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) {
    Widget f(TextEditingController t, String l) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: t,
        obscureText: true,
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
        ),
      ),
    );
    return AlertDialog(
      title: const Text('Ubah Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          f(o, 'Password lama'),
          f(n, 'Password baru'),
          f(c, 'Ulangi password baru'),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(err!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (o.text != store.me!.password) {
              return setState(() => err = 'Password lama salah');
            }
            if (n.text.length < 6) {
              return setState(() => err = 'Password baru minimal 6 karakter');
            }
            if (n.text != c.text) {
              return setState(() => err = 'Konfirmasi password tidak sama');
            }
            store.me!.password = n.text;
            Navigator.pop(context);
            toast(context, 'Password berhasil diubah');
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
class UserDialog extends StatefulWidget {
  const UserDialog({super.key});
  @override
  State<UserDialog> createState() => _UserDialogState();
}
class _UserDialogState extends State<UserDialog> {
  final nm = TextEditingController(),
      un = TextEditingController(),
      pw = TextEditingController();
  String role = 'Kasir';
  String? err;
  @override
  Widget build(BuildContext context) {
    Widget f(TextEditingController t, String l, {bool obs = false}) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: t,
        obscureText: obs,
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
        ),
      ),
    );
    return AlertDialog(
      title: const Text('Tambah Pengguna'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            f(nm, 'Nama lengkap'),
            f(un, 'Username'),
            f(pw, 'Password', obs: true),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: role,
              items: const [
                DropdownMenuItem(value: 'Kasir', child: Text('Kasir')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => role = v!),
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
            if (err != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(err!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (nm.text.trim().isEmpty ||
                un.text.trim().isEmpty ||
                pw.text.length < 6) {
              return setState(
                () => err = 'Lengkapi data (password min. 6 karakter)',
              );
            }
            if (store.users.any((x) => x.username == un.text.trim())) {
              return setState(() => err = 'Username sudah dipakai');
            }
            store.users.add(
              AppUser(nm.text.trim(), un.text.trim(), pw.text, role),
            );
            store.touch();
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
// ============================ PROMO ============================
int soldToday(Product p) {
  final t = dateOnly(DateTime.now());
  return store
      .between(t, t)
      .fold(
        0,
        (a, s) =>
            a +
            s.lines.where((l) => l.name == p.name).fold(0, (b, l) => b + l.qty),
      );
}
Widget priceRow(Product p, Promo x) => Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: rp(p.price),
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      TextSpan(
        text: '  →  ${rp(x.apply(p.price))}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    ],
  ),
);
List<Widget> promoReminders(void Function(int) go) {
  final list = store.activePromos;
  if (list.isEmpty) {
    return [
      const Card(
        child: ListTile(
          leading: Icon(Icons.notifications_none),
          title: Text('Tidak ada promo aktif hari ini'),
        ),
      ),
    ];
  }
  return [
    for (final x in list)
      Builder(
        builder: (_) {
          final p = store.byId(x.productId);
          return Card(
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.amber.shade600),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔔 Promo Hari Ini – ${p.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${x.label}  •  berlaku ${x.periode}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        priceRow(p, x),
                        Text(
                          'Status: ${x.status}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () => go(1), child: const Text('Jual')),
                ],
              ),
            ),
          );
        },
      ),
  ];
}
class PromoPage extends StatelessWidget {
  const PromoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = [...store.promos]
          ..sort((a, b) => b.start.compareTo(a.start));
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Promo'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PromoForm()),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada promo')),
                ),
              for (final x in list) _card(context, x),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
  Widget _card(BuildContext context, Promo x) {
    final p = store.byId(x.productId);
    final st = x.status;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${x.label} • ${x.periode}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      priceRow(p, x),
                    ],
                  ),
                ),
                Chip(
                  label: Text(st, style: const TextStyle(fontSize: 11)),
                  backgroundColor: promoColor(st).withValues(alpha: .18),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Aktif'),
                Switch(
                  value: x.enabled,
                  onChanged: (v) {
                    x.enabled = v;
                    store.touch();
                  },
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PromoForm(promo: x)),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Hapus promo?'),
                        content: Text('Promo ${p.name} akan dihapus.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      store.promos.remove(x);
                      store.touch();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class PromoForm extends StatefulWidget {
  final Promo? promo;
  const PromoForm({super.key, this.promo});
  @override
  State<PromoForm> createState() => _PromoFormState();
}
class _PromoFormState extends State<PromoForm> {
  final key = GlobalKey<FormState>();
  late String pid = widget.promo?.productId ?? store.products.first.id;
  late String type = widget.promo?.type ?? 'persen';
  late final value = TextEditingController(
    text: widget.promo?.value.toString(),
  );
  late DateTime start = widget.promo?.start ?? dateOnly(DateTime.now());
  late DateTime end =
      widget.promo?.end ??
      dateOnly(DateTime.now()).add(const Duration(days: 5));
  late bool enabled = widget.promo?.enabled ?? true;
  String? err;
  String? vv(String? s) {
    final n = int.tryParse(s ?? '');
    if (n == null || n <= 0) return 'Isi dengan angka lebih dari 0';
    if (type == 'persen' && n > 100) return 'Maksimal 100%';
    return null;
  }
  Future<void> pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (d == null) return;
    setState(() {
      if (isStart) {
        start = d;
      } else {
        end = d;
      }
    });
  }
  void save() {
    if (!key.currentState!.validate()) return;
    if (end.isBefore(start)) {
      return setState(
        () => err = 'Tanggal berakhir tidak boleh sebelum tanggal mulai',
      );
    }
    final v = int.parse(value.text);
    final x = widget.promo;
    if (x == null) {
      store.promos.add(
        Promo(
          'PR${DateTime.now().microsecondsSinceEpoch}',
          pid,
          type,
          v,
          start,
          end,
          enabled,
        ),
      );
    } else {
      x
        ..productId = pid
        ..type = type
        ..value = v
        ..start = start
        ..end = end
        ..enabled = enabled;
    }
    store.touch();
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final p = store.byId(pid);
    final after = Promo(
      'x',
      pid,
      type,
      int.tryParse(value.text) ?? 0,
      start,
      end,
    ).apply(p.price);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.promo == null ? 'Tambah Promo' : 'Edit Promo'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: key,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: pid,
                  items: [
                    for (final x in store.products)
                      DropdownMenuItem(
                        value: x.id,
                        child: Text('${x.emoji} ${x.name}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => pid = v!),
                  decoration: const InputDecoration(
                    labelText: 'Pilih produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Harga normal',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    rp(p.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'persen', label: Text('Diskon %')),
                    ButtonSegment(
                      value: 'potongan',
                      label: Text('Potongan Harga'),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setState(() => type = s.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: value,
                  validator: vv,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Nilai promo',
                    suffixText: type == 'persen' ? '%' : null,
                    prefixText: type == 'persen' ? null : 'Rp ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text('Mulai: ${tgl(start)}'),
                        onPressed: () => pick(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event_available),
                        label: Text('Berakhir: ${tgl(end)}'),
                        onPressed: () => pick(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.amber.shade50,
                  child: ListTile(
                    title: const Text('Harga setelah promo'),
                    trailing: Text(
                      rp(after),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Status promo aktif'),
                  value: enabled,
                  onChanged: (v) => setState(() => enabled = v),
                ),
                if (err != null)
                  Text(err!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: save,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
