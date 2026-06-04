local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local PartyService = {}

local MAX_MEMBERS = 8
local MAX_LEVEL_DIFFERENCE = 9
local INVITE_TIMEOUT = 30

local parties = {}
local playerPartyIds = {}
local pendingInvites = {}

local function getData(profiles, player)
	return profiles[player]
end

local function getParty(player)
	local partyId = playerPartyIds[player.UserId]
	return partyId and parties[partyId] or nil
end

local function getMemberSnapshot(player, data, party)
	local stats = data.Stats or {}

	return {
		UserId = player.UserId,
		Name = data.Name or player.Name,
		Level = data.Level or 1,
		Role = data.StartingClassId or "Member",
		FactionId = data.FactionId,
		IsLeader = party.LeaderUserId == player.UserId,
		HP = stats.HP or stats.MaxHP or 150,
		MaxHP = stats.MaxHP or 150,
		FP = stats.FP or stats.MaxFP or 100,
		MaxFP = stats.MaxFP or 100,
	}
end

local function syncParty(profiles, party)
	local members = {}

	for _, userId in ipairs(party.MemberUserIds) do
		local memberPlayer = Players:GetPlayerByUserId(userId)
		local memberData = memberPlayer and getData(profiles, memberPlayer)

		if memberPlayer and memberData then
			table.insert(members, getMemberSnapshot(memberPlayer, memberData, party))
		end
	end

	for _, userId in ipairs(party.MemberUserIds) do
		local memberPlayer = Players:GetPlayerByUserId(userId)
		local memberData = memberPlayer and getData(profiles, memberPlayer)

		if memberData then
			memberData.Party = {
				Id = party.Id,
				LeaderUserId = party.LeaderUserId,
				IsLeader = party.LeaderUserId == userId,
				Locked = party.Locked,
				LootMode = party.LootMode,
				Capacity = MAX_MEMBERS,
				Members = members,
			}
		end
	end

	return members
end

local function clearPartyData(profiles, userId)
	local player = Players:GetPlayerByUserId(userId)
	local data = player and getData(profiles, player)

	if data then
		data.Party = nil
	end
end

local function removeMemberUserId(memberUserIds, userId)
	for index, memberUserId in ipairs(memberUserIds) do
		if memberUserId == userId then
			table.remove(memberUserIds, index)
			return
		end
	end
end

local function hasMember(party, userId)
	for _, memberUserId in ipairs(party.MemberUserIds) do
		if memberUserId == userId then
			return true
		end
	end

	return false
end

local function createParty(leader)
	local party = {
		Id = HttpService:GenerateGUID(false),
		LeaderUserId = leader.UserId,
		MemberUserIds = { leader.UserId },
		Locked = false,
		LootMode = "All",
	}

	parties[party.Id] = party
	playerPartyIds[leader.UserId] = party.Id

	return party
end

local function validateInvite(inviter, target, profiles)
	if not inviter or not target then
		return false, "Target player not found"
	end

	if inviter == target then
		return false, "Cannot invite yourself"
	end

	local inviterData = getData(profiles, inviter)
	local targetData = getData(profiles, target)

	if not inviterData or not targetData then
		return false, "Player data not ready"
	end

	if not inviterData.FactionId or not targetData.FactionId then
		return false, "Both players must choose a race first"
	end

	if inviterData.FactionId ~= targetData.FactionId then
		return false, "Party members must be the same race"
	end

	local levelDifference = math.abs((inviterData.Level or 1) - (targetData.Level or 1))

	if levelDifference > MAX_LEVEL_DIFFERENCE then
		return false, "Level difference must be below 10"
	end

	local party = getParty(inviter)
	local targetParty = getParty(target)

	if targetParty then
		return false, "Target is already in a party"
	end

	if party then
		if party.LeaderUserId ~= inviter.UserId then
			return false, "Only the party leader can invite"
		end

		if party.Locked then
			return false, "Party is locked"
		end

		if #party.MemberUserIds >= MAX_MEMBERS then
			return false, "Party is full"
		end
	end

	return true, party
end

function PartyService.RequestInvite(inviter, targetUserId, profiles)
	local target = Players:GetPlayerByUserId(tonumber(targetUserId) or 0)
	local ok, result = validateInvite(inviter, target, profiles)

	if not ok then
		return false, result
	end

	local party = result or createParty(inviter)
	syncParty(profiles, party)

	pendingInvites[target.UserId] = {
		PartyId = party.Id,
		InviterUserId = inviter.UserId,
		ExpiresAt = os.clock() + INVITE_TIMEOUT,
	}

	return true,
		{
			PartyId = party.Id,
			InviterUserId = inviter.UserId,
			InviterName = inviter.Name,
			TargetUserId = target.UserId,
			TargetName = target.Name,
			ExpiresIn = INVITE_TIMEOUT,
		}
end

function PartyService.RespondToInvite(player, accepted, profiles)
	local invite = pendingInvites[player.UserId]

	if not invite then
		return false, "No pending party invite"
	end

	pendingInvites[player.UserId] = nil

	if os.clock() > invite.ExpiresAt then
		return false, "Party invite expired"
	end

	if not accepted then
		return true, "Declined"
	end

	local party = parties[invite.PartyId]
	local inviter = Players:GetPlayerByUserId(invite.InviterUserId)

	if not party or not inviter then
		return false, "Party no longer exists"
	end

	if hasMember(party, player.UserId) then
		return true, getData(profiles, player).Party
	end

	local ok, reason = validateInvite(inviter, player, profiles)

	if not ok then
		return false, reason
	end

	table.insert(party.MemberUserIds, player.UserId)
	playerPartyIds[player.UserId] = party.Id
	syncParty(profiles, party)

	return true, getData(profiles, player).Party
end

function PartyService.LeaveParty(player, profiles)
	local party = getParty(player)

	if not party then
		return false, "Not in a party"
	end

	removeMemberUserId(party.MemberUserIds, player.UserId)
	playerPartyIds[player.UserId] = nil
	clearPartyData(profiles, player.UserId)

	if #party.MemberUserIds <= 1 then
		for _, userId in ipairs(party.MemberUserIds) do
			playerPartyIds[userId] = nil
			clearPartyData(profiles, userId)
		end

		parties[party.Id] = nil
		return true, "Party dissolved"
	end

	if party.LeaderUserId == player.UserId then
		party.LeaderUserId = party.MemberUserIds[1]
	end

	syncParty(profiles, party)

	return true, "Left party"
end

function PartyService.ToggleLock(player, profiles)
	local party = getParty(player)

	if not party then
		return false, "Not in a party"
	end

	if party.LeaderUserId ~= player.UserId then
		return false, "Only the party leader can lock party"
	end

	party.Locked = not party.Locked
	syncParty(profiles, party)

	return true, getData(profiles, player).Party
end

function PartyService.GetPartyData(player, profiles)
	local party = getParty(player)

	if not party then
		local data = getData(profiles, player)

		if data then
			data.Party = nil
		end

		return nil
	end

	syncParty(profiles, party)
	return getData(profiles, player).Party
end

function PartyService.OnPlayerRemoving(player, profiles)
	pendingInvites[player.UserId] = nil
	PartyService.LeaveParty(player, profiles)
end

return PartyService
