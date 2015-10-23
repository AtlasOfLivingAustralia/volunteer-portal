function digivolStats(config) {
  function avatarUrl() {
    return "http://www.gravatar.com/avatar/"+this.email()+"?s=40&d=mm"
  }

  function userProfileUrl() {
    return config.userProfileUrl.replace("-1", this.userId())
  }

  function LeaderBoardEntryVM(data) {
    var self = this;
    ko.mapping.fromJS(data, {}, this);
    self.src = ko.pureComputed(avatarUrl, this);
    self.userProfileUrl = ko.pureComputed(userProfileUrl, this);
  }
  function ContributorEntryVM(data) {
    var self = this;
    ko.mapping.fromJS(data, {}, this);
    self.avatarUrl = ko.pureComputed(avatarUrl, this);
    self.userProfileUrl = ko.pureComputed(userProfileUrl, this);
    self.additionalTranscribedThumbs = ko.pureComputed(function() {
      return Math.max(self.transcribedItems() - 5, 0);
    }, this);
    self.projectUrl = ko.pureComputed(function() {
      return config.projectUrl.replace('-1', self.projectId());
    }, this);
  }
  var mapping = {
    'daily': {
      create: function(options) {
        return new LeaderBoardEntryVM(options.data);
      }
    },
    'weekly': {
      create: function(options) {
        return new LeaderBoardEntryVM(options.data);
      }
    },
    'monthly': {
      create: function(options) {
        return new LeaderBoardEntryVM(options.data);
      }
    },
    'alltime': {
      create: function(options) {
        return new LeaderBoardEntryVM(options.data);
      }
    },
    'contributors': {
      create: function(options) {
        return new ContributorEntryVM(options.data);
      }
    }
  };
  var viewModel = ko.mapping.fromJS({
    loading : true,
    transcriberCount: null,
    completedTasks: null,
    totalTasks: null,
    daily: { userId: -1, email: '', name: '', score: null },
    weekly: { userId: -1, email: '', name: '', score: null },
    monthly: { userId: -1, email: '', name: '', score: null },
    alltime: { userId: -1, email: '', name: '', score: null },
    contributors: []
  }, mapping);

  jQuery(function($) {
    ko.applyBindings(viewModel, document.getElementById('digivol-stats'));

    var p = $.get(config.statsUrl, { institutionId: config.institutionId, maxContributors: config.maxContributors }, $.noop, 'json');
    p.done(function(data, status, jqXHR) {
      viewModel.loading(false);
      ko.mapping.fromJS(data, viewModel);
    });
  });
}