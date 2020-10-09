{{ define "head" }}
<meta name="robots" content="noindex" />
<meta property="og:site_name" content="Let's Debug" />
<meta property="og:title" content="Test result for {{ .Test.Domain }}: {{ .Test.Severity }}" />
<meta property="og:description" content="{{ .Test.LongSummary }}" />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://letsdebug.net/{{ .Test.Domain }}/{{ .Test.ID}}" />
<style>
.problem {
  padding: 1rem;
  margin: 1rem 0;
}
.problem-Warning {
  color: black;
  background: rgba(255, 166, 0, 0.657);
}
.problem-Warning a, .problem-Warning a:visited {
  color: black;
}
.problem-Error, .problem-Error a, .problem-Error a:visited {
  color: #eee;
  background: rgb(155, 41, 0);
}
.problem-Fatal {
  color: darkred;
  background-color: rgba(255,0,0,0.25);
}
.problem-Fatal a, .problem-Fatal a:visited {
  color: darkred;
}
.problem-OK {
  color: #eee;
  background: rgb(0, 77, 0);
}
.problem-Debug, .problem-Debug a, .problem-Debug a:visited {
  background: lightskyblue;
  color: black;
}
.problem-OK a, .problem-OK a:visited {
  color: #eee;
  text-decoration: underline;
}
.problem-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
.problem-name {
  font-weight: bold;
}
.problem-description {
  margin: 1rem 0;
  font-size: 1.05rem;
}
.problem-detail {
  font-size: 0.9rem;  
}
.problem-severity {
  text-transform: uppercase;
  font-size: 0.8em;
}
.times {
  font-size: 0.75rem;
  color: #333;
}
.recheck-form {
  display: inline;
}
.recheck-form input[type='submit'] {
  border: none;
  background: white;
  color: #2c3c69;
  cursor: pointer;
  font-size: 0.75rem;
}
</style>
{{ end }}
{{ define "body" }}
<div class="container">
  <a href="/"><h1>Let's Debug</h1></a>

  {{ if .Error }}
  <section class="error">{{ .Error }}</section>
  <section class="description">
    <p><a href="/">Go back to the start.</a></p>
  </section>
  {{ else }}

  <h2>Test result for <a href="/{{ .Test.Domain}}">{{ .Test.Domain }}</a> using {{ .Test.Method }}
    {{ if eq .Test.Status "Complete" }}
    <form action="/" method="POST" class="recheck-form">
      <input type="hidden" name="domain" value="{{ .Test.Domain }}">
      <input type="hidden" name="method" value="{{ .Test.Method }}">
      <input type="submit" value="(Rerun test)">
    </form>
    {{ end }}
  </h2>

  {{ if eq .Test.Status "Cancelled" }}
  <section class="error">
    This test was cancelled by the server, sorry! You may try again. <a href="/">Go back to the start.</a>
  </section>
  {{ else if ne .Test.Status "Complete"}}
  <section class="description">
    The test is currently {{ .Test.Status }} ... please wait, this page will refresh automatically ...
    {{ if .Test.IsRunningLong }}
    <div class="warning">
      This test has been running for a while. Usually this indicates that one or more of the domain's nameservers
      are either inaccessible or offline. Please be patient, it may take 5-15 minutes but this test should eventually complete.
    </div>
    {{ end }}
  </section>
  {{ else if .Test.Result.Error }}
  <section class="results">
    <p>Unfortunately something went wrong when running the test.</p>
    <div class="error">{{ .Test.Result.Error }}</div>
  </section>
  {{ else if not .Test.Result.Problems }}
  <section class="results">
    <div class="problem problem-OK">
      <div class="problem-header">
        <div class="problem-name">All OK!</div>
        <div class="problem-severity">OK</div>
      </div>
      <div class="problem-description">
        <p>No issues were found with {{ .Test.Domain }}. If you are having problems with creating an SSL certificate,
          please visit the <a href="https://community.letsencrypt.org/" target="_blank" rel="noopener noreferrer">
          Let's Encrypt Community forums</a> and post a question there.
        </p>
      </div>
    </div>
  </section>
  {{ else }}
  <section class="results">
    {{ $test := .Test }}
    {{ range $index, $problem := .Test.Result.Problems }}
    <div class="problem problem-{{ $problem.Severity }}" id="{{ $problem.Name }}-{{ $problem.Severity }}">
      <div class="problem-header">
          <div class="problem-name"><a href="#{{ $problem.Name }}-{{ $problem.Severity }}">{{ $problem.Name }}</a></div>
          <div class="problem-severity">{{ $problem.Severity }}</div>    
      </div>
      <div class="problem-description">{{ $problem.Explanation }} </div>
      <div class="problem-detail">
        {{ if eq $problem.Name "UnboundLogs" }}
        <a href="/{{ $test.Domain }}/{{ $test.ID }}/unboundlogs">Click here to view unbound logs.</a><p />Note: These logs are only available for 7 days after a test is submitted.
        {{ else }}
        {{ range $dIndex, $detail := $problem.DetailLines }}{{ $detail }} <br/>{{ end }}
        {{ end }}
      </div>
    </div>
    {{ end }}
  </section>
  {{ end }}
  <section class="description">
    <p class="times">Submitted <abbr title="{{ .Test.CreatedTimestamp }}">{{ .Test.SubmitTime }}</abbr>.
    {{ if .Test.QueueDuration }}Sat in queue for {{ .Test.QueueDuration }}.{{ end }}
    {{ if .Test.TestDuration }}Completed in {{ .Test.TestDuration }}.{{ end }}
    {{ if eq .Test.Status "Complete" }}
    {{ if .Debug }} <a href="/{{ .Test.Domain }}/{{ .Test.ID}}">Hide verbose information.</a>
    {{ else }} <a href="/{{ .Test.Domain }}/{{ .Test.ID}}?debug=y">Show verbose information.</a> {{ end }}
    {{ end }}
  </p>
  </section>        
  {{ end }}
</div>
{{ end }}
{{ template "base" . }}