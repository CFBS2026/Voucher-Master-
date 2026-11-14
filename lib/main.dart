import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://yuuosbpjewsrfvbpmers.supabase.co';
const supabaseAnonKey = 'sb_publishable_QLVpvd3NQ2AKAtVJF2muHA_tq93VSrF';
final supabase = Supabase.instance.client;
const navy = Color(0xFF071B3A);
const blue = Color(0xFF164477);
const gold = Color(0xFFFFC857);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const VoucherMasterApp());
}

class VoucherMasterApp extends StatelessWidget {
  const VoucherMasterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Voucher Master Pro',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      scaffoldBackgroundColor: const Color(0xFFF2F5FA),
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
    ),
    home: const SessionGate(),
  );
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: supabase.auth.onAuthStateChange,
    builder: (_, __) => supabase.auth.currentUser == null
      ? const LoginPage()
      : const ApprovalGate(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false, register = false, obscure = true;
  String? error;
  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(() => error = 'Gmail နှင့် Password (အနည်းဆုံး ၆ လုံး) ဖြည့်ပါ။');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      if (register) {
        await supabase.auth.signUp(email: email.text.trim(), password: password.text);
        if (mounted) setState(() => error = 'အကောင့်ဖွင့်ပြီးပါပြီ။ Email အတည်ပြုပြီး Admin ခွင့်ပြုချက်ကို စောင့်ပါ။');
      } else {
        await supabase.auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (e) {
      if (mounted) setState(() => error = 'Login မအောင်မြင်ပါ: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [navy, blue])),
      child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium, size: 64, color: gold),
              const SizedBox(height: 8),
              const Text('VOUCHER MASTER', style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 24, color: navy)),
              const Text('Smart WiFi Management'),
              const SizedBox(height: 24),
              TextField(controller: email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Gmail Address',
                  prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: obscure,
                decoration: InputDecoration(labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscure = !obscure)),
                  border: const OutlineInputBorder())),
              if (error != null) Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 48,
                child: FilledButton(onPressed: busy ? null : submit,
                  child: busy ? const CircularProgressIndicator() :
                    Text(register ? 'CREATE ACCOUNT' : 'LOGIN'))),
              TextButton(onPressed: busy ? null : () => setState(() => register = !register),
                child: Text(register ? 'Already registered? Login' : 'Create account')),
            ]),
          )),
        ),
      )),
    ),
  );
}

class ApprovalGate extends StatelessWidget {
  const ApprovalGate({super.key});
  Future<Map<String, dynamic>?> readAccess() async {
    return await supabase.from('app_access').select(
      'approved,is_admin,display_name').eq(
      'user_id', supabase.auth.currentUser!.id).maybeSingle();
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(
    future: readAccess(),
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (snap.hasError)
        return Scaffold(body: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Account permission စစ်ဆေးမရပါ။\n${snap.error}'))));
      final access = snap.data;
      if (access == null || access['approved'] != true)
        return const PendingPage();
      return DashboardPage(
        isAdmin: access['is_admin'] == true,
        displayName: (access['display_name'] ??
          supabase.auth.currentUser?.email ?? 'User').toString());
    },
  );
}

class PendingPage extends StatelessWidget {
  const PendingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(
    child: Padding(padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.hourglass_top_rounded, size: 68, color: blue),
        const SizedBox(height: 14),
        const Text('Approval Pending', style: TextStyle(
          fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('သင့် Gmail အကောင့်ကို VM Admin မှ ခွင့်ပြုရန် စောင့်ဆိုင်းနေပါသည်။',
          textAlign: TextAlign.center),
        const SizedBox(height: 18),
        FilledButton(onPressed: () => supabase.auth.signOut(),
          child: const Text('Logout')),
      ]),
    ),
  ));
}


class DashboardPage extends StatefulWidget {
  final bool isAdmin;
  final String displayName;

  const DashboardPage({
    super.key,
    required this.isAdmin,
    required this.displayName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> projects = [];
  String? projectId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final result = await supabase
          .from('projects')
          .select('id,name')
          .order('created_at');

      projects = List<Map<String, dynamic>>.from(result);

      if (projects.isNotEmpty) {
        projectId ??= projects.first['id'].toString();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> addProject() async {
    final name = TextEditingController();

    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Project အသစ်'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Project Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (yes == true && name.text.trim().isNotEmpty) {
      try {
        final row = await supabase
            .from('projects')
            .insert({
              'name': name.text.trim(),
              'owner_id': supabase.auth.currentUser!.id,
            })
            .select('id')
            .single();

        projectId = row['id'].toString();
        await loadProjects();
      } catch (e) {
        toast('Project သိမ်းမရပါ: $e');
      }
    }

    name.dispose();
  }

  void toast(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      ('Voucher Manager', 'Voucher Code များ စီမံခန့်ခွဲခြင်း',
          Icons.confirmation_number, 'vouchers'),
      ('Connected Devices', 'ချိတ်ဆက်ထားသော ဖုန်းများ',
          Icons.devices, 'connected_devices'),
      ('Blacklist Devices', 'ပိတ်ပင်ထားသော ဖုန်းများ',
          Icons.block, 'blocked_devices'),
      ('Print Setting', 'WiFi Name နှင့် Voucher Style',
          Icons.print, 'print_settings'),
      ('Revenue', 'ဝင်ငွေစာရင်း',
          Icons.trending_up, 'revenue_entries'),
      ('Top Traffic', 'အသုံးပြုမှု အများဆုံး Device များ',
          Icons.bar_chart, 'traffic_devices'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Master Pro'),
        actions: [
          IconButton(
            onPressed: () => supabase.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadProjects,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [navy, blue],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONNECT • MANAGE • GROW',
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Welcome, ${widget.displayName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.folder_open, color: gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: projects.any(
                                  (p) =>
                                      p['id'].toString() == projectId,
                                )
                                    ? projectId
                                    : null,
                                isExpanded: true,
                                dropdownColor: blue,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                hint: const Text(
                                  'Select Project',
                                  style: TextStyle(color: Colors.white),
                                ),
                                items: projects.map((p) {
                                  return DropdownMenuItem(
                                    value: p['id'].toString(),
                                    child: Text(p['name'].toString()),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  setState(() => projectId = v);
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: addProject,
                              icon: const Icon(
                                Icons.add_circle,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...modules.map(
                    (m) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: blue,
                          child: Icon(m.$3, color: Colors.white),
                        ),
                        title: Text(
                          m.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(m.$2),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModulePage(
                                title: m.$1,
                                table: m.$4,
                                projectId: projectId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.admin_panel_settings),
                      ),
                      title: const Text('Admin Approval'),
                      subtitle: const Text(
                        'Gmail account ခွင့်ပြု / ပိတ်သိမ်းရန်',
                      ),
                      onTap: () {
                        if (!widget.isAdmin) {
                          toast('Admin permission လိုအပ်ပါသည်။');
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text('Delete Expired Vouchers'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModulePage(
                              title: 'Expired Vouchers',
                              table: 'vouchers',
                              projectId: projectId,
                              expiredOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}


class ModulePage extends StatefulWidget {
  final String title, table;
  final String? projectId;
  final bool expiredOnly;
  const ModulePage({super.key, required this.title, required this.table,
    this.projectId, this.expiredOnly = false});
  @override State<ModulePage> createState() => _ModulePageState();
}
class _ModulePageState extends State<ModulePage> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String? error;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      if (widget.projectId == null) throw Exception('Project ကို အရင်ရွေးပါ။');
      var query = supabase.from(widget.table).select();
      query = query.eq('project_id', widget.projectId!);
      if (widget.expiredOnly) query = query.lt('expires_at', DateTime.now().toIso8601String());
      final data = await query;
      rows = List<Map<String, dynamic>>.from(data);
    } catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: loading ? const Center(child: CircularProgressIndicator()) :
      error != null ? Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Backend data မရရှိပါ။\n$error', textAlign: TextAlign.center))) :
      RefreshIndicator(onRefresh: load, child: ListView(
        padding: const EdgeInsets.all(12),
        children: rows.isEmpty
          ? [const Padding(padding: EdgeInsets.all(28),
              child: Center(child: Text('စာရင်းမရှိသေးပါ')))]
          : rows.map((r) => Card(child: ListTile(
              title: Text((r['name'] ?? r['code'] ?? r['device_name'] ?? r['id'] ?? 'Record').toString()),
              subtitle: Text(r.entries.where((e) => e.key != 'id').take(4)
                .map((e) => '${e.key}: ${e.value}').join(' • ')),
            ))).toList(),
      )),
  );
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override State<AdminPage> createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      final data = await supabase.rpc('admin_list_app_users');
      users = List<Map<String, dynamic>>.from(data);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  Future<void> setApproval(String id, bool approved) async {
    try {
      await supabase.rpc('admin_set_app_access',
        params: {'target_user_id': id, 'new_approved': approved});
      await load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Approval')),
    body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView(children: users.map((u) => SwitchListTile(
        title: Text(u['email']?.toString() ?? ''),
        subtitle: Text(u['is_admin'] == true ? 'Admin' : 'Customer'),
        value: u['approved'] == true,
        onChanged: (v) => setApproval(u['user_id'].toString(), v),
      )).toList()),
  );
}
