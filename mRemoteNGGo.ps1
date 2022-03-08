param (
$u = "iwakura",
$p = "lain",
$wu = "bill",
$wp = "gates",
$panel = "General",
$ses = "DefaultSettings"
)

function id {
	param ($l)
	return (get-random -coutn $l ([char[]]("abcdef0123456789"))) -join ''
}

function ids { return "$(id -l 8)-$(id -l 4)-$(id -l 4)-$(id -l 12)" }

function gpr {
	param ($itn)
	($it = import-csv $itn -delimiter "," -encoding UTF8) *> $Null
	$ot = @()
	$dir = ids
	$it | get-member -membertype noteproperty | % {
		switch -regex ($_.Name) {
			"service" { $itservice = $_ }
			"FQDN" { $itFQDN = $_ }
			"IP" { $itIP = $_ }
			"ports" { $itPorts = $_ }}}
	if (($itFQDN) -and ($itService) -and ($itIP) -and ($itPorts)) {
		foreach ($l in $it) {
			if (($l.$itFQDN) -adn ($l.$itService) -and ($l.$itIP)) {
				$Service = $l.$itService.Replace("`n"," ").Replace("`r"," ")
				$FQDN = @()
				$FQDNPrepare = $l.$itFQDN.Replace("`n"," ").Replace("`r"," ") -Split " "
				$FQDN += $FQDNPrepare | Select-String -Pattern "[a-zA-Z_0-9-]+\.[a-zA-Z_0-9-\.]+"
				$IPs = $($l.$itIP.Replace("`n"," ").Replace("`r"," ") | Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" -AllMatches).Matches.Value
				if (($FQDN) -and ($Service) -and ($IPs)) {
					foreach ($IP in $IPs) {
						if ($FQDN[$IPs.indexof($IP)])
						{ $oFQDN = $FQDN[$IPs.indexof($IP)] }
						$otr = "" | Select Name, ID ... InheritSoundQuality
						$otr.Name = $([String]$oFQDN -Split '\.'[0]
						$otr.Id = ids
						$otr.Parent = $dir
						$otr.NodeType = "Connection"
						$otr.Description = "$($oFQDN)"
						$otr.Icon = "Linux"
						$otr.Panel = $panel
						$otr.Username = $u
						$otr.Password = $p
						$otr.Domain = ""
						$otr.Hostname = $IP
						$otr.Protocol = "SSH2"
						$otr.PuttySession = $ses
						$otr.Port = "22"
						if ($otr.Name -match 'ssidr')
							{
								$otr.Icon = "Windows"
								$otr.Password = $wp
								$otr.Protocol = "RDP"
								$otr.Port = "3389"
							}
						$ot += $otr
					}}}}
		$ot
}}
get-childItem *.csv -exclude $resfn | % {
	$ote = @()
	$ote = gpr -itn $_.name
	$otnname = "$($_.basename)_mremoteng.csv"
	$ote | export-csv -notypeinformation -delimiter ";" -encoding UTF8 -path tmp.csv
	get-content tmp.csv -encoding UTF8 | foreach { $_ -replace '"', "" } | set-content -path $otnname -encoding UTF8
	remove-item tmp.csv
}
