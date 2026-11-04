<div id="domain-alert-container" class="domain-alert">
    <div class="alert alert-${style} p-0 overflow-hidden" role="alert">
        <!-- Optional Alert Header/Padding -->
        <div class="p-3 pb-0">
            <h4 class="alert-heading fw-bold">${alertTitle}</h4>
            <p class="mb-2">${alertDescription}</p>
            <button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>

        <!-- Flush List Group inside Alert -->
        <g:hasErrors bean="${attachedBean}">
            <ul class="list-group list-group-flush">
            <al:renderErrors attachedBean="${attachedBean}" style="${style}"/>
            </ul>
        </g:hasErrors>
        <g:if test="${alertList}">
            <ul class="list-group list-group-flush">
                <g:each in="${alertList}" var="item">
                    <li class="list-group-item list-group-item-${style}">${item}</li>
                </g:each>
            </ul>
        </g:if>
    </div>
</div>