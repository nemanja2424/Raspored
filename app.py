from flask import Flask, render_template, url_for, request, redirect, session, jsonify, request
import mysql.connector
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import timedelta
from flask_jwt_extended import JWTManager, create_access_token, get_jwt, jwt_required, get_jwt_identity

con = mysql.connector.connect(
    host='localhost',
    port='3306',
    user='root',
    passwd='n3m4nj41M4K4',
    database='kalendar'
)
mycursor = con.cursor(dictionary=True)
app = Flask (__name__)

app.config['JWT_SECRET_KEY'] = 'tvoj_tajni_jwt_kljuc'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=5)
jwt = JWTManager(app)

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>LOGIN
@app.route('/login', methods=['POST'])
def login():
    forma = request.json
    upit = "SELECT user.userID, user.email, user.lozinka, rola.ime AS rola_ime FROM user INNER JOIN rola ON user.rola = rola.rolaID WHERE user.email = %s"
    vrednost = (forma['email'],)
    mycursor.execute(upit, vrednost)
    korisnik = mycursor.fetchone()

    if korisnik and check_password_hash(korisnik['lozinka'], forma['lozinka']):
        access_token = create_access_token(
            identity=korisnik['email'],
            additional_claims={
                "rola": korisnik['rola_ime'],
                "userID": korisnik['userID']
            }
        )
        return jsonify({"message": "Uspešno ste se prijavili.", "access_token": access_token, "rola": korisnik['rola_ime'], "id": korisnik['userID']}), 200
    else:
        return jsonify({"message": "Neispravni podaci za prijavu."}), 401

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>KALENDAR
@app.route('/kalendar/<int:id>', methods=['GET'])
@jwt_required()
def kalendar(id):
    upit = """
        SELECT
            desavanja.desavanjaID,
            desavanja.naslov,
            desavanja.opis,
            desavanja.celodnevni,
            desavanja.datum,
            COALESCE(desavanja.odTime, '') AS odTime,
            COALESCE(desavanja.doTime, '') AS doTime,
            desavanja.gotov,
            desavanja.kategD,
            desavanja.kreiran
        FROM 
            desavanja 
        WHERE IDUsera = %s;
    """
    vrednost = (id,)
    mycursor.execute(upit, vrednost)
    desavanja = mycursor.fetchall()

    return jsonify(desavanja), 200
@app.route('/novo-desavanje/<datum>', methods=['POST'])
@jwt_required()
def novo_desavanje(datum):
    datum = datum.replace('%20', ' ')
    forma = request.get_json()
    upit = "INSERT INTO desavanja (naslov, odTime, doTime, celodnevni, opis, datum, kategD, IDUsera) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
    vrednosti = (forma['naslov'], forma['odTime'], forma['doTime'], forma['celodnevni'], forma['opis'], forma['datum'], forma['kategD'], forma['IDUsera'])
    mycursor.execute(upit, vrednosti)
    con.commit()
    return jsonify({"message": "Uspešno ste dodali dešavanje"}), 200
@app.route('/delete-event/<int:id>', methods=['DELETE'])
@jwt_required()
def obrisi_desavanje(id):
    mycursor.execute("DELETE FROM desavanja WHERE desavanjaID = %s", (id,))
    con.commit()
    return jsonify({"message": "Uspešno ste obrisali dešavanje."}), 200
@app.route('/izmena-desavanja/<int:id>', methods=['GET', 'PUT'])
@jwt_required()
def izmeni_desavanje(id):
    if request.method == "GET":
        upit = """
        SELECT
            desavanja.desavanjaID,
            desavanja.naslov,
            desavanja.opis,
            desavanja.celodnevni,
            desavanja.datum,
            COALESCE(desavanja.odTime, '') AS odTime,
            COALESCE(desavanja.doTime, '') AS doTime,
            desavanja.gotov,
            desavanja.kategD,
            desavanja.kreiran
        FROM 
            desavanja 
        WHERE desavanjaID = %s;
    """
        vrednost = (id,)
        mycursor.execute(upit, vrednost)
        result = mycursor.fetchone()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"message": "Dešavanje nije pronađeno."}), 404
    if request.method == "PUT":
        forma = request.json
        upit = "UPDATE desavanja SET naslov=%s, odTime=%s, doTime=%s, celodnevni=%s, opis=%s, kategD=%s WHERE desavanjaID=%s;"
        vrednosti = (forma['naslov'], forma['odTime'], forma['doTime'], forma['celodnevni'], forma['opis'], forma['kategD'], id)
        mycursor.execute(upit, vrednosti)
        con.commit()
        return jsonify({"message": "Uspešno ste izmenili dešavanje."}), 200
    
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ZADACI
@app.route('/zadaci/<int:id>', methods=['GET', 'POST'])
@jwt_required()
def zadaci(id):
    if request.method == "GET":
        upit = "SELECT * FROM zadaci WHERE IDUsera = %s;"
        vrednost = (id,)
        mycursor.execute(upit, vrednost)
        desavanja = mycursor.fetchall()
        return jsonify(desavanja), 200
    if request.method == "POST":
        forma = request.get_json()
        upit = "INSERT INTO zadaci (IDUsera, opis, jednokratni, rok, uradjeno, brojac, kategZ) VALUE (%s, %s, %s, %s, %s, %s, %s)"
        vrednosti = (id, forma['opis'], forma['jednokratni'], forma['rok'], forma['uradjeno'], forma['brojac'], forma['kategZ'])
        mycursor.execute(upit, vrednosti)
        con.commit()
        return jsonify({"message": "Uspešno ste dodali zadatak"}), 200
@app.route('/izmena-zadataka/<int:id>', methods=['PUT', 'DELETE', 'GET'])
@jwt_required()
def zadaciIzmene(id):
    if request.method == "PUT":
        forma = request.get_json()
        upit = """
            UPDATE zadaci
            SET
                opis = %s,
                uradjeno = %s,
                jednokratni = %s,
                brojac = %s,
                rok = %s,
                kategZ = %s
            WHERE
                zadatakID = %s;
        """
        vrednosti = (forma ['opis'], forma['uradjeno'], forma['jednokratni'], forma['brojac'], forma['rok'], forma['kategZ'], id)
        mycursor.execute(upit, vrednosti)
        con.commit()
        return jsonify({"message": "Uspešno ste izmenili zadatak"}), 200
    if request.method == "DELETE":
        mycursor.execute("DELETE FROM zadaci WHERE zadatakID = %s;", (id,))
        con.commit()
        return jsonify({"message": "Uspešno ste obrisali zadatak."}), 200
    if request.method == "GET":
        upit = "SELECT * FROM zadaci WHERE zadatakID = %s;"
        vrednost = (id,)
        mycursor.execute(upit, vrednost)
        result = mycursor.fetchone()
        return jsonify(result), 200
@app.route('/brojac/<int:id>', methods=['POST', 'DELETE'])
@jwt_required()
def brojacIstorija(id):
    if request.method == "POST":
        mycursor.execute("INSERT INTO istorijaZadataka (IDZadatka) VALUE (%s)", (id,))
        con.commit()
        return jsonify({"message": "Uspešno ste zabeležili istoriju zadatka."}), 200
    if request.method == "DELETE":
        mycursor.execute("DELETE FROM istorijaZadataka WHERE IDZadatka = %s", (id,))
        con.commit()
        return jsonify({"message": "Uspešno ste obrisali istoriju zadatka."}), 200

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ADMIN
@app.route('/admin', methods=['GET'])
@jwt_required()
def admin_panel():
    upit_users = """
        SELECT 
            user.userID,
            user.ime,
            user.email,
            user.lozinka,
            rola.ime AS rola_ime,
            user.kreirano
        FROM 
            user
        INNER JOIN 
            rola ON user.rola = rola.rolaID;
    """
    mycursor.execute(upit_users)
    svi_korisnici = mycursor.fetchall()
    upit_desavanja = """
        SELECT
            desavanja.desavanjaID,
            desavanja.naslov,
            desavanja.opis,
            desavanja.celodnevni,
            desavanja.datum,
            COALESCE(desavanja.odTime, '') AS odTime,
            COALESCE(desavanja.doTime, '') AS doTime,
            desavanja.gotov,
            desavanja.kreiran,
            `user`.ime AS korisnik_ime
        FROM 
            desavanja
        INNER JOIN 
            `user` ON desavanja.IDUsera = `user`.userID;

        """

    mycursor.execute(upit_desavanja)
    sva_desavanja = mycursor.fetchall()

    upit_zadaci = """
        SELECT 
            zadaci.zadatakID,
            zadaci.opis,
            zadaci.jednokratni,
            zadaci.uradjeno,
            zadaci.brojac,
            zadaci.kreiran,
            zadaci.rok,
            zadaci.kategZ,
            user.ime AS korisnicko_ime
        FROM 
            zadaci
        INNER JOIN 
            user ON zadaci.IDUsera = user.userID;
    """
    mycursor.execute(upit_zadaci)
    svi_zadaci = mycursor.fetchall()

    admin_data = {
        "korisnici": svi_korisnici,
        "desavanja": sva_desavanja,
        "zadaci": svi_zadaci
    }

    return jsonify(admin_data), 200

@app.route('/novi-korisnik', methods=['POST'])
@jwt_required()
def noviKorisnik():
    forma = request.get_json()
    upit = "INSERT INTO user (ime, email, lozinka, rola) VALUE (%s, %s, %s, %s);"
    hashLozinka = generate_password_hash(forma['lozinka'])
    vrednosti = (forma['ime'], forma['email'], hashLozinka, forma['rola'])
    mycursor.execute(upit, vrednosti)
    con.commit()
    return jsonify({"message": "Uspešno ste dodali korisnika"}), 200
@app.route('/izmenak/<int:id>', methods=['DELETE', 'PUT', 'GET'])
@jwt_required()
def izmenaK(id):
    if request.method == "PUT":
        forma = request.get_json()
        upit = "UPDATE user SET ime = %s, email = %s, rola = %s"
        vrednosti = [forma['ime'], forma['email'], forma['rola']]
        if forma['lozinka']:
            hashLozinka = generate_password_hash(forma['lozinka'])
            upit += ", lozinka = %s"
            vrednosti.append(hashLozinka)

        upit += " WHERE userID = %s"
        vrednosti.append(id)

        mycursor.execute(upit, tuple(vrednosti))
        con.commit()
        return jsonify({"message": "Uspešno ste izmenili korisnika"}), 200
    if request.method == "GET":
        mycursor.execute("SELECT * FROM user WHERE userID = %s", (id,))
        korisnik = mycursor.fetchone()
        return jsonify(korisnik), 200
    if request.method == "DELETE":
        mycursor.execute("DELETE FROM user WHERE userID = %s", (id,))
        con.commit()
        return jsonify({"message": "Uspešno ste obrisali korisnika."}), 200
@app.route('/brisanje-svega/<tabela>', methods=['DELETE'])
@jwt_required()
def brisanjeSvega(tabela):
    allowed_tables = ["zadaci", "desavanja"]
    if tabela not in allowed_tables:
        return jsonify({"error": "Nevažeća tabela."}), 400

    upit = f"DELETE FROM {tabela};"
    mycursor.execute(upit)
    con.commit()
    return jsonify({"message": "Uspešno ste obrisali sve podatke."}), 200
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>KATEGORIJE
@app.route('/kategorije/<int:id>', methods=['POST', 'GET'])
@jwt_required()
def kategorije(id):
    if request.method == "GET":
        mycursor.execute("SELECT * FROM kategorije WHERE IDUsera = %s OR IDUsera IS NULL;", (id,))
        kategorije = mycursor.fetchall()
        return jsonify(kategorije), 200
    if request.method == "POST":
        forma = request.get_json()
        mycursor.execute("INSERT INTO kategorije (imeKateg, IDUsera) VALUE (%s, %s)", (forma['imeKateg'], id))
        con.commit()
        return jsonify({"message": "Uspešno ste dodali kategoriju"}), 200
    
@app.route('/izmena-kateg/<int:id>', methods=['DELETE', 'PUT'])
@jwt_required()
def izmenaKateg(id):
    if request.method == "DELETE":
        mycursor.execute("DELETE FROM kategorije WHERE kategID = %s", (id,))
        con.commit()
        return jsonify({"message": "Uspešno ste obrisali kategoriju."}), 200
    if request.method == "PUT":
        forma = request.get_json()
        upit = "UPDATE kategorije SET imeKateg = %s WHERE kategID = %s"
        vrednosti = (forma['imeKateg'], id)
        mycursor.execute(upit, vrednosti)
        con.commit()
        return jsonify({"message": "Uspešno ste izmenili kategoriju."}), 200


if __name__ == "__main__":
    app.run(debug=True)