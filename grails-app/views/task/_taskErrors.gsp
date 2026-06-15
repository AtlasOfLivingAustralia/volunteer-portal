<g:if test="${!errors || errors.isEmpty()}">
    <div class="alert alert-info">No errors recorded for this task descriptor.</div>
</g:if>
<g:else>
    <div class="list-group">
        <g:each in="${errors}" var="err" status="i">
            <div class="list-group-item">
                <div class="d-flex w-100 justify-content-between">
                    <h6 class="mb-1">${err?.type ?: 'Error'}</h6>
                    <small class="text-muted">${g.formatDate(date: err?.dateCreated, format:'dd/MM/yyyy HH:mm:ss')}</small>
                </div>
                <p class="mb-1">${err?.message ?: err?.toString()}</p>
                <small class="text-muted stackTrace"><pre>${err.stacktrace}</pre></small>
            </div>
        </g:each>
    </div>
</g:else>