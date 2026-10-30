<!-- Tutorial List Modal -->
<div class="modal fade" id="tutorialsModal" tabindex="-1" aria-labelledby="tutorialsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg rounded-4">

            <!-- Modal Header -->
            <div class="modal-header border-bottom-0 pb-0 pt-4 px-4 align-items-center">
                <div class="d-flex align-items-center gap-3">
                    <div class="bg-light p-2 rounded-3 border d-flex align-items-center justify-content-center" style="width: 54px; height: 54px;">
                        <img src="" id="institution-logo" alt="Logo" class="img-fluid" style="max-height: 100%; object-fit: contain;">
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold fs-5 mb-0" id="tutorialsModalLabel">{{institution_name}}</h5>
                        <p class="text-muted small mb-0" id="tutorial-count">{{tutorial_count}}</p>
                    </div>
                </div>
                <button type="button" class="btn-close align-self-start" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <!-- Modal Body -->
            <div class="modal-body p-4">

                <!-- Search Filter inside Modal -->
                <div class="mb-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 text-muted"><i class="fa fa-search"></i></span>
                        <input type="text" class="form-control bg-light border-start-0 ps-0" placeholder="Filter tutorials by title..." id="tutorial-search">
                        <label class="visually-hidden" for="tutorial-search">Search Tutorials</label>
                    </div>
                </div>

                <!-- Tutorial Items List -->
                <div id="tutorial-list" class="list-group list-group-flush gap-2">

                </div>
            </div>

            <div class="d-none" id="tutorial-template">
                <div id="tutorial-row" class="list-group-item list-group-item-action p-3 rounded-3 border d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
                    <div>
                        <h6 class="fw-semibold mb-1 text-dark">{{tutorial_title}}</h6>
                        <p class="text-secondary small mb-0">{{tutorial_description}}</p>
                    </div>
                    <a href="{{tutorial_url}}" target="_blank" rel="noopener noreferrer" class="btn btn-outline-primary btn-sm rounded text-nowrap flex-shrink-0">

                    Open Tutorial <i class="fa fa-arrow-right ms-1"></i>
                    </a>
                </div>
            </div>

            <!-- Modal Footer -->
            <div class="modal-footer border-top-0 pt-0 px-4 pb-4 justify-content-between">
                <span class="text-muted small">Need help? <a href="mailto:digivol@australian.museum?subject=Tutorial%20help" class="text-decoration-none">Contact Support</a></span>
                <button type="button" class="btn btn-light rounded px-4" data-bs-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>

