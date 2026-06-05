from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'club_sportif_secret'

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="club_sport"
    )

# ============================================================
# TABLEAU DE BORD
# ============================================================
@app.route('/')
def dashboard():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("SELECT COUNT(*) AS total FROM Membre")
    membres_actifs = cursor.fetchone()['total']

    cursor.execute("""
        SELECT COUNT(*) AS total FROM Cotisation 
        WHERE statut = 'impayee' AND saison = '2025-2026'
    """)
    cotisations_impayees = cursor.fetchone()['total']

    cursor.execute("""
        SELECT c.*, s.nom AS sport_nom FROM Competition c
        JOIN Sport s ON c.id_sport = s.id_sport
        WHERE c.date_comp >= CURDATE() ORDER BY c.date_comp ASC LIMIT 5
    """)
    competitions = cursor.fetchall()

    cursor.close(); db.close()
    return render_template('dashboard.html',
        membres_actifs=membres_actifs,
        cotisations_impayees=cotisations_impayees,
        competitions=competitions
    )

# ============================================================
# MEMBRES
# ============================================================
@app.route('/membres')
def membres():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Membre ORDER BY nom")
    membres = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('membres.html', membres=membres)

@app.route('/membres/ajouter', methods=['GET', 'POST'])
def ajouter_membre():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    if request.method == 'POST':
        sql = """INSERT INTO Membre 
                 (num_licence, nom, prenom, date_naissance, telephone, email, date_adhesion)
                 VALUES (%s, %s, %s, %s, %s, %s, CURDATE())"""
        cursor.execute(sql, (
            request.form['num_licence'],
            request.form['nom'],
            request.form['prenom'],
            request.form['date_naissance'],
            request.form['telephone'],
            request.form['email']
        ))
        db.commit()
        flash('Membre ajouté !', 'success')
        cursor.close(); db.close()
        return redirect(url_for('membres'))
    cursor.close(); db.close()
    return render_template('membre_form.html')

@app.route('/membres/<string:id>')
def fiche_membre(id):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("SELECT * FROM Membre WHERE num_licence = %s", (id,))
    membre = cursor.fetchone()

    cursor.execute("""
        SELECT e.nom AS equipe, a.poste, s.nom AS sport
        FROM Appartenance a
        JOIN Equipe e ON a.code_equipe = e.code_equipe
        JOIN Sport s ON e.id_sport = s.id_sport
        WHERE a.num_licence = %s AND a.date_sortie IS NULL
    """, (id,))
    equipes = cursor.fetchall()

    cursor.execute("""
        SELECT * FROM Cotisation WHERE num_licence = %s ORDER BY saison DESC
    """, (id,))
    cotisations = cursor.fetchall()

    cursor.execute("""
        SELECT COUNT(*) AS total,
               SUM(CASE WHEN present = 1 THEN 1 ELSE 0 END) AS presences
        FROM Presence WHERE num_licence = %s
    """, (id,))
    assiduite = cursor.fetchone()

    cursor.close(); db.close()
    return render_template('membre_fiche.html',
        membre=membre, equipes=equipes,
        cotisations=cotisations, assiduite=assiduite)

# ============================================================
# ENTRAÎNEMENTS
# ============================================================
@app.route('/entrainements')
def entrainements():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.*, eq.nom AS equipe_nom FROM Entrainement e
        JOIN Equipe eq ON e.code_equipe = eq.code_equipe
        ORDER BY e.date_seance DESC
    """)
    entrainements = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('entrainements.html', entrainements=entrainements)

@app.route('/entrainements/ajouter', methods=['GET', 'POST'])
def ajouter_entrainement():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    if request.method == 'POST':
        sql = """INSERT INTO Entrainement 
                 (code_equipe, date_seance, heure_debut, duree, lieu, theme)
                 VALUES (%s, %s, %s, %s, %s, %s)"""
        cursor.execute(sql, (
            request.form['equipe'],
            request.form['date'],
            request.form['heure_debut'],
            request.form['duree'],
            request.form['lieu'],
            request.form['theme']
        ))
        entrainement_id = cursor.lastrowid
        db.commit()
        cursor.close(); db.close()
        return redirect(url_for('saisir_presences', id=entrainement_id))
    cursor.execute("SELECT * FROM Equipe")
    equipes = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('entrainement_form.html', equipes=equipes)

@app.route('/entrainements/<int:id>/presences', methods=['GET', 'POST'])
def saisir_presences(id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.*, eq.nom AS equipe_nom, eq.code_equipe
        FROM Entrainement e JOIN Equipe eq ON e.code_equipe = eq.code_equipe
        WHERE e.id_entrainement = %s
    """, (id,))
    entrainement = cursor.fetchone()

    if request.method == 'POST':
        cursor.execute("""
            SELECT num_licence FROM Appartenance
            WHERE code_equipe = %s AND date_sortie IS NULL
        """, (entrainement['code_equipe'],))
        membres = cursor.fetchall()
        presents = request.form.getlist('presents')
        for m in membres:
            licence = m['num_licence']
            present = 1 if licence in presents else 0
            motif = request.form.get(f'motif_{licence}', '')
            cursor.execute("""
                INSERT INTO Presence 
                (id_entrainement, num_licence, present, motif_absence)
                VALUES (%s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE present=%s, motif_absence=%s
            """, (id, licence, present, motif, present, motif))
        db.commit()
        flash('Présences enregistrées !', 'success')
        cursor.close(); db.close()
        return redirect(url_for('entrainements'))

    cursor.execute("""
        SELECT m.* FROM Membre m
        JOIN Appartenance a ON m.num_licence = a.num_licence
        WHERE a.code_equipe = %s AND a.date_sortie IS NULL
    """, (entrainement['code_equipe'],))
    membres = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('presences.html', entrainement=entrainement, membres=membres)

# ============================================================
# COTISATIONS
# ============================================================
@app.route('/cotisations')
def cotisations():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT c.*, m.nom, m.prenom FROM Cotisation c
        JOIN Membre m ON c.num_licence = m.num_licence
        WHERE c.saison = '2025-2026' ORDER BY c.statut, m.nom
    """)
    cotisations = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('cotisations.html', cotisations=cotisations)

@app.route('/cotisations/payer/<string:membre_id>', methods=['POST'])
def payer_cotisation(membre_id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        UPDATE Cotisation SET statut = 'payee', date_paiement = CURDATE()
        WHERE num_licence = %s AND saison = '2025-2026'
    """, (membre_id,))
    db.commit()
    flash('Cotisation payée !', 'success')
    cursor.close(); db.close()
    return redirect(url_for('cotisations'))

# ============================================================
# COMPÉTITIONS
# ============================================================
@app.route('/competitions')
def competitions():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT c.*, s.nom AS sport_nom FROM Competition c
        JOIN Sport s ON c.id_sport = s.id_sport
        ORDER BY c.date_comp DESC
    """)
    competitions = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('competitions.html', competitions=competitions)

@app.route('/competitions/ajouter', methods=['GET', 'POST'])
def ajouter_competition():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    if request.method == 'POST':
        cursor.execute("""
            INSERT INTO Competition (nom, id_sport, date_comp, lieu, type_comp)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            request.form['nom'],
            request.form['sport'],
            request.form['date'],
            request.form['lieu'],
            request.form['type']
        ))
        db.commit()
        flash('Compétition créée !', 'success')
        cursor.close(); db.close()
        return redirect(url_for('competitions'))
    cursor.execute("SELECT * FROM Sport")
    sports = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('competition_form.html', sports=sports)

if __name__ == '__main__':
    app.run(debug=True)