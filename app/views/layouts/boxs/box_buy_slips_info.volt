<div class="col-xl-2 col-sm-6 text-left">
    <div class="btn-group">
        <button type="button" class="btn btn-info" id="show_slips_info" data-toggle="modal" data-target="#modal_slips_info" aria-haspopup="true" aria-expanded="false">BOLETOS:</button>
        <button type="text" class="btn btn-info dropdown-toggle-split" disabled="disabled" id="num_slips">
            <span class="text-white">0</span>
        </button>
    </div>

    <div class="modal fade" id="modal_slips_info" tabindex="-1" role="dialog" aria-labelledby="modal_slips_info" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-sm" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 style="color:black;" class="modal-title">Información de los boletos</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th scope="col" style="color: black !important;">Boleto</th>
                                        <th scope="col" style="color: black !important;">Bloques</th>
                                        <th scope="col" style="color: black !important;">Completo</th>
                                    </tr>
                                </thead>
                                <tbody id="slips_info"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</div>