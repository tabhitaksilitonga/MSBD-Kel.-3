SELECT 
    rolname AS nama_peran,
    rolcanlogin AS dapat_login,
    rolsuper AS superuser
FROM pg_roles
WHERE rolname IN ('postgres', 'skema_owner', 'app_read', 'app_write', 'app_laporan', 'app_portal', 'app_analitik')
ORDER BY rolcanlogin DESC, rolname;