<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.getProperty('ala.skin', String)}"/>
    <g:set var="entityName" value="${message(code: 'user.label')}"/>
    <title><cl:pageTitle title="${message(code: 'default.tutorials.label', default: 'Tutorials')}"/></title>

    <asset:stylesheet src="notebook-reset.css"/>
    <asset:stylesheet src="tutorials-2.scss"/>
</head>
<body>

<cl:headerContent hideTitle="true" selectedNavItem="tutorials">

    <!-- Header Section with Search and Filter Controls -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
        <div>
            <h1 class="fw-bold mb-1">${message(code: 'default.tutorials.label', default: 'Tutorials')}</h1>
            <p class="text-secondary mb-0">Browse tutorials published by participating institutions.</p>
        </div>

        <div class="d-flex gap-2">
            <!-- Search Bar -->
            <div class="input-group">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa fa-search"></i></span>
                <input type="text" class="form-control border-start-0 ps-0" placeholder="Search Institutions..." id="search-institutions">
                <label class="visually-hidden" for="search-institutions">Search Institutions</label>
            </div>

            <!-- Filter Dropdown -->
            <label>
                <select class="form-select w-auto">
                    <option selected>Sort by Name</option>
                    <option value="most">Most Tutorials</option>
                </select>
            </label>
        </div>
    </div>

</cl:headerContent>

<div class="container py-5">
    <!-- Cards Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-4 g-4">

        <!-- Featured Card: DigiVol Administration -->
        <div class="col">
            <div class="card h-100 rounded-3 shadow-sm org-card featured border-0">
                <div class="card-body d-flex flex-column justify-content-between p-4">
                    <div class="mb-4">
    %{--                    <img src="digivol-logo.png" alt="DigiVol Logo" style="max-height: 45px; width: auto;" class="brightness-filter">--}%
                        <asset:image class="institution-logo-parent" src="digivol-logo-email.png" style="max-height: 45px; width: auto;" alt="DigiVol Administration Tutorials"/>
                    </div>
                    <div>
                        <h5 class="card-title fw-semibold text-white mb-2">
                            <a href="#" data-bs-toggle="modal" data-bs-target="#tutorialsModal" data-institution-id="admin" class="text-white text-decoration-none stretched-link">DigiVol Administration</a>
                        </h5>
                        <span class="badge rounded-pill bg-white text-danger px-3 py-2 fw-medium">
                            <i class="fa fa-book me-1"></i>${tutorialAdminCount} tutorials
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <g:each in="${tutorialGroups}" var="institution">
        <div class="col">
            <div class="card h-100 rounded-3 shadow-sm org-card bg-white">
                <div class="logo-container">
                    <img class="institution-logo-parent" src="<cl:institutionLogoUrl id="${institution.id}"/>" alt="${institution.name}">
                </div>
                <div class="card-body d-flex flex-column justify-content-between p-4">
                    <h5 class="card-title fw-semibold text-dark fs-6 mb-3">
                        <a href="#" data-bs-toggle="modal" data-bs-target="#tutorialsModal" data-institution-id="${institution.id}" class="text-dark text-decoration-none stretched-link">${institution.name}</a>
                    </h5>
                    <div>
                        <span class="badge rounded-pill bg-primary-subtle text-primary border border-primary-subtle px-2.5 py-1.5 fw-medium">
                            <i class="fa fa-book me-1"></i> ${institution.tutorials.size()} tutorial<g:if test="${institution.tutorials.size() > 1}">s</g:if>
                        </span>
                    </div>
                </div>
            </div>
        </div>
        </g:each>

    </div>
</div>

<g:render template="tutorialListModal"/>

<asset:script>
    <g:set var="baseUrl" value="${grailsApplication.config.getProperty('server.url', String) + grailsApplication.config.getProperty('images.urlPrefix', String) }"/>
    const BASE_URL = "${baseUrl + "tutorials/"}";

    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('search-institutions');
        const institutionCards = document.querySelectorAll('.org-card');
        const tutorialsModal = document.getElementById('tutorialsModal');
        const tutorialSearchInput = document.getElementById('tutorial-search');

        searchInput.addEventListener('input', function () {
            const filter = searchInput.value.toLowerCase();

            institutionCards.forEach(card => {
                const institutionName = card.querySelector('.card-title a').textContent.toLowerCase();
                if (institutionName.includes(filter)) {
                    card.parentElement.style.display = ''; // Show the card
                } else {
                    card.parentElement.style.display = 'none'; // Hide the card
                }
            });
        });

        // Populate modal content when opened from a card trigger.
        tutorialsModal.addEventListener('show.bs.modal', function (event) {
            const trigger = event.relatedTarget;
            if (!trigger) {
                return;
            }
            const card = trigger.closest('.org-card');
            const institutionName = trigger.textContent.trim();
            const tutorialCount = card ? card.querySelector('.badge')?.textContent.trim() : '';
            const institutionLogoElement = card ? card.querySelector('.institution-logo-parent') : null;
            tutorialSearchInput.value = ''; // Clear the search input in the modal

            // Set the modal content
            document.getElementById('tutorialsModalLabel').textContent = institutionName;
            if (institutionLogoElement) {
                document.getElementById('institution-logo').src = institutionLogoElement.src;
            }
            document.getElementById('tutorial-count').textContent = tutorialCount;

            // Get the list of institutions via ajax call to the server
            const institutionId = trigger.getAttribute('data-institution-id');
            const queryParam = 'institutionId=' + encodeURIComponent(institutionId);
            fetch('${createLink(controller: "tutorials", action: "tutorialListForInstitution")}?' + queryParam)
                .then(response => response.json())
                .then(tutorials => {
                    const tutorialListContainer = document.querySelector('#tutorial-list');
                    tutorialListContainer.innerHTML = ''; // Clear existing tutorials
                    let tutorialTemplate = document.getElementById('tutorial-template').innerHTML;
                    tutorials.forEach(tutorial => {
                        let listItem = document.createElement('div');
                        listItem.innerHTML = tutorialTemplate
                            .replace('{{tutorial_title}}', tutorial.name)
                            .replace('{{tutorial_description}}', tutorial.description)
                            .replace('{{tutorial_url}}', BASE_URL + tutorial.filename);
                        tutorialListContainer.appendChild(listItem.firstElementChild);
                    });
                });
        });

        tutorialSearchInput.addEventListener('input', function () {
            const filter = tutorialSearchInput.value.toLowerCase();
            const tutorialList = document.getElementById('tutorial-list');
            const tutorialItems = tutorialList.querySelectorAll('.list-group-item');
            tutorialItems.forEach(item => {
                const title = item.querySelector('h6').textContent.toLowerCase();
                if (title.includes(filter)) {
                    item.style.removeProperty('display');
                } else {
                    item.style.setProperty('display', 'none', 'important');
                }
            });
        });

    });

</asset:script>


</body>
</html>

