<div class="col-12">
    <div class="row justify-content-center align-items-center">
        <div class="col-12">
            <h3>Docs</h3>
        </div>
        <div class="col-12 col-lg-4 bg-white p-3">
            <form method="post">
                <div class="form-group">
                    <label for="user">Usuario</label>
                    <input type="text" class="form-control" id="user" name="user">
                </div>
                <div class="form-group">
                    <label for="password">Contraseña</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Password">
                </div>
                {% if loginError is defined %}
                    <div class="alert alert-danger mt-3" role="alert">{{loginError}}</div>
                {% endif %}
                <button type="submit" class="btn btn-primary">Submit</button>
            </form>
        </div>
    </div>
</div>
