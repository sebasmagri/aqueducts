{ pkgs }:

let
    sharedLibraryFileType = if pkgs.stdenv.isDarwin then "dylib" else "so";
in
pkgs.mkShell {
    buildInputs = with pkgs; [
        cargo
        iconv
        openssl
        postgresql
        rustc
        sqlite
        unixODBC
        unixODBCDrivers.msodbcsql18
        unixODBCDrivers.mariadb
        unixODBCDrivers.psql
        unixODBCDrivers.sqlite
    ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
        darwin.apple_sdk.frameworks.Security
    ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
        unixODBCDrivers.redshift
    ];

    env = {
        PROMPT_DIRTRIM = "2";
    };

    # This needs testing and tweaking for Linux
    shellHook = ''
    export PS1="(aqueducts) \[\e[1;34m\]\w\[\e[0m\] > "
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.unixODBC}/lib:${pkgs.openssl.out}/lib"

    export ODBCSYSINI=$(realpath ./)
    export ODBCINI=$(realpath ./odbc.ini)
    cat > $ODBCINI << EOF
    [ODBC]
    Trace=Yes
    TraceFile=./odbc.log

    [sqlserver]
    Description=Microsoft ODBC Driver 18 for SQL Server
    Driver=${pkgs.unixODBCDrivers.msodbcsql18}/libmsodbcsql-18.${sharedLibraryFileType}

    [mariadb]
    Description=MariaDB ODBC Driver
    Driver=${pkgs.unixODBCDrivers.mariadb}/libmaodbc.${sharedLibraryFileType}

    [postgresql]
    Description=PostgreSQL ODBC Driver
    Driver=${pkgs.unixODBCDrivers.psql}/libpsqlodbcw.${sharedLibraryFileType}

    [sqlite]
    Description=SQLite ODBC Driver
    Driver=${pkgs.unixODBCDrivers.sqlite}/lib/libsqlite3odbc.${sharedLibraryFileType}
    Setup=${pkgs.unixODBCDrivers.sqlite}/lib/libsqlite3odbc.${sharedLibraryFileType}
    Threading=2

    EOF

    echo "Installing aqueducts-cli..."
    cargo install aqueducts-cli --all-features --force
    echo ""
    echo "Welcome to the aqueducts shell!"
    echo ""
    echo "ODBC Drivers available:"
    echo "  - MariaDB/MySQL: DSN={mariadb}"
    echo "  - SQL Server: DSN={msodbcsql18}"
    echo "  - PostgreSQL: DSN={postgresql}"
    echo "  - Redshift: DSN={redshift} (Linux only, requires manual configuration in ./odbc.ini)"
    echo "  - SQLite: DSN={sqlite}"
    echo ""
    echo "Additional utilities available:"
    echo "  - psql (PostgreSQL CLI)"
    echo "  - sqlite3 (SQLite CLI)"
    echo "  - isql (and the rest of the unixODBC admin CLI tools)"
    echo ""
    echo "Check the docs at https://github.com/vigimite/aqueducts to know more."
    echo ""
    echo "Run 'aqueducts --help' to get started."
    echo ""
    '';
}
